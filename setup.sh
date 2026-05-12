#!/bin/bash
# LD ToyPad Emulator — Auto Setup Script v1.5.0
# Usage: curl -sSL https://raw.githubusercontent.com/YOUR_FORK/LD-ToyPad-Emulator/master/setup.sh | bash
#
# What this does:
#   1. Installs dependencies and configures USB gadget (idempotent)
#   2. Detects your CPU architecture and pulls the correct container image
#   3. Creates and starts the container with persistent image + config mounts
#   4. Sets up autostart on boot via cron
#   5. Configures mDNS so the emulator is reachable at http://toypad.local

set -e

REPO="ghcr.io/berny23/ld-toypad-emulator:latest"
IMAGES_DIR="$HOME/LD-ToyPad-Emulator/server/images"
CONTAINER_NAME="ld-toypad-emulator"

# ── Colours ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Step 1: USB gadget + dependencies ────────────────────────────────────────
info "Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq git libusb-1.0-0-dev libudev-dev podman avahi-daemon

info "Configuring USB gadget overlay..."
BOOT_CONFIG=""
[[ -f /boot/firmware/config.txt ]] && BOOT_CONFIG="/boot/firmware/config.txt" || BOOT_CONFIG="/boot/config.txt"

grep -q "dtoverlay=dwc2" "$BOOT_CONFIG" || echo "dtoverlay=dwc2" | sudo tee -a "$BOOT_CONFIG" > /dev/null
grep -q "^dwc2"          /etc/modules   || echo "dwc2"          | sudo tee -a /etc/modules   > /dev/null
grep -q "^libcomposite"  /etc/modules   || echo "libcomposite"  | sudo tee -a /etc/modules   > /dev/null

info "Cloning repository..."
if [[ ! -d "$HOME/LD-ToyPad-Emulator" ]]; then
  git clone https://github.com/Glitxhhh/LD-ToyPad-Emulator.git "$HOME/LD-ToyPad-Emulator"
fi

info "Installing USB setup service..."
sudo cp "$HOME/LD-ToyPad-Emulator/usb_setup_script.sh" /usr/local/bin/toypad_usb_setup.sh
sudo chmod +x /usr/local/bin/toypad_usb_setup.sh

# Append UDC activation + hidg0 permission to the setup script
if ! grep -q "hidg0" /usr/local/bin/toypad_usb_setup.sh; then
  printf '\necho "$UDC" > UDC\nsleep 2;\nchmod a+rw /dev/hidg0\n' \
    | sudo tee -a /usr/local/bin/toypad_usb_setup.sh > /dev/null
fi

(sudo crontab -l 2>/dev/null | grep -v toypad_usb_setup; \
 echo "@reboot sudo /usr/local/bin/toypad_usb_setup.sh") | sudo crontab -

# ── Step 2: Detect architecture ──────────────────────────────────────────────
ARCH=$(uname -m)
case "$ARCH" in
  aarch64)  PLATFORM="linux/arm64"   ;;
  armv7l)   PLATFORM="linux/arm/v7"  ;;
  armv6l)   PLATFORM="linux/arm/v6"  ;;
  x86_64)   PLATFORM="linux/amd64"   ;;
  *)        error "Unsupported architecture: $ARCH" ;;
esac
info "Detected architecture: $ARCH → $PLATFORM"

# ── Step 3: Pull container image ─────────────────────────────────────────────
info "Pulling container image for $PLATFORM..."
if ! podman pull --platform="$PLATFORM" "$REPO" 2>/dev/null; then
  warn "Platform flag not accepted by this Podman version — trying digest fallback..."
  # Digest map for armv7 (Bookworm 32-bit Pi)
  case "$ARCH" in
    armv7l) DIGEST="sha256:e27d9e54b8dc7cfd2f478d98c10e4a2c4e89b9a57cdd6d749a8f431590aed07f" ;;
    *)      error "Could not pull image for $ARCH. Check the package registry manually." ;;
  esac
  podman pull "${REPO}@${DIGEST}"
  REPO="${REPO}@${DIGEST}"
fi

# ── Step 4: Create container ──────────────────────────────────────────────────
mkdir -p "$IMAGES_DIR"

info "Removing old container if present..."
podman rm -f "$CONTAINER_NAME" 2>/dev/null || true

info "Creating container..."
podman create \
  --name "$CONTAINER_NAME" \
  -p 80:80 \
  --device /dev/hidg0:/dev/hidg0 \
  -v "$IMAGES_DIR:/app/server/images:Z" \
  -v "$HOME/LD-ToyPad-Emulator/server/index.html:/app/server/index.html:Z" \
  -v "$HOME/LD-ToyPad-Emulator/server/stylesheets/main.css:/app/server/stylesheets/main.css:Z" \
  -v "$HOME/LD-ToyPad-Emulator/server/scripts/main.js:/app/server/scripts/main.js:Z" \
  "$REPO"

# ── Step 5: Autostart ─────────────────────────────────────────────────────────
(crontab -l 2>/dev/null | grep -v "$CONTAINER_NAME"; \
 echo "@reboot sleep 12 && podman start $CONTAINER_NAME") | crontab -

# ── Step 6: mDNS ─────────────────────────────────────────────────────────────
info "Enabling mDNS (Avahi)..."
sudo systemctl enable --now avahi-daemon 2>/dev/null || true

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup complete! Rebooting in 5 seconds...${NC}"
echo -e "${GREEN}  After reboot, open: http://toypad.local${NC}"
echo -e "${GREEN}  (port 80 — no port number needed)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 5
sudo shutdown -r now
