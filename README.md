# Toy Pad Emulator for Lego Dimensions

<a href="https://www.buymeacoffee.com/Berny23" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a>

Allows you to connect an emulated Toy Pad to your PC or video-game console.

## Features

- Confirmed working on **[Cemu](https://www.youtube.com/watch?v=7CBa9u2ip-Y)**, **real Wii U**, [**RPCS3**](#rpcs3-cannot-detect-the-toy-pad), [**real PS3**](https://github.com/Berny23/LD-ToyPad-Emulator/issues/10#issuecomment-933027554), [**real PS4**](https://www.reddit.com/r/Legodimensions/comments/pb32zg/comment/hamfj29/?utm_source=share&utm_medium=web2x&context=3) and [**real PS5**](https://github.com/Berny23/LD-ToyPad-Emulator/issues/45)
- Supports **all available characters and vehicles**
- Saves **vehicle upgrades**
- Displays the Toy Pad's **light effects**
- Supports smart scrolling for **mobile devices**
- Can be run in a **virtual machine** on Windows, macOS and Linux
- **No copyrighted game files are required**, nor are any included
- **Dark mode** with persistent preference
- **Keyboard shortcuts** (1–7) to place/remove tokens without touching the mouse
- **Custom character images** with automatic multi-image cycling

## Demo

![image](https://user-images.githubusercontent.com/36038743/151242123-8dee84e5-6276-4ac2-ba58-c09bff121419.png)

## Videos

- First demo video on Cemu emulator: https://www.youtube.com/watch?v=7CBa9u2ip-Y
- Installation tutorial on a virtual machine: https://www.youtube.com/watch?v=5PARAnrt1jU
- Quick usage showcase on RPCS3: https://www.youtube.com/watch?v=KIKDO0dxYl4

## Installation

**There are two options.** Please choose the installation method that suits your needs best.

<hr>

### Option 1: Virtual Machine (only for emulators)

#### Prerequisites

- Either [VMware Player](https://www.vmware.com/products/workstation-player.html) (free), [VMware Workstation Pro](https://www.vmware.com/products/workstation-pro.html) (paid) or [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads) (free)
- [Debian 11.1 ISO](https://cdimage.debian.org/mirror/cdimage/archive/11.1.0/amd64/iso-cd/debian-11.1.0-amd64-netinst.iso) (newer versions not tested)
- [VirtualHere USB Client](https://www.virtualhere.com/usb_client_software) for Windows, Linux or MacOS

#### Guide

1. Make a new virtual machine with Debian in your software of choice. Select your ISO file and choose the appropriate operating system (Linux -> Debian 11.x 64-bit) if you're asked. **To make sure your VM is accessible on the network, please follow the instructions in the troubleshooting section on this page (either for [VirtualBox](#webpage-not-reachable-oracle-virtualbox) or [VMware](#webpage-not-reachable-vmware)).**

2. When first booting the Debian VM, select `Graphical install`. In the configuration, leave everything on default. Only change your language, set `debian` as hostname, don't set a root password, choose an account name and password, set partition to "yes" and `/dev/sda` for the GRUB bootloader.

3. After rebooting, log in with your password. Then click the menu on the upper left corner, search for "Terminal" and open it.

4. Run the following commands (you can copy and paste with right click):

   ```bash
   sudo apt update
   sudo apt install -y git usbip hwdata curl python build-essential libusb-1.0-0-dev libudev-dev
   echo "usbip-core" | sudo tee -a /etc/modules
   echo "usbip-vudc" | sudo tee -a /etc/modules
   echo "vhci-hcd" | sudo tee -a /etc/modules

   echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
   echo "dwc2" | sudo tee -a /etc/modules
   echo "libcomposite" | sudo tee -a /etc/modules
   echo "usb_f_rndis" | sudo tee -a /etc/modules

   git config pull.rebase false
   git clone https://github.com/Berny23/LD-ToyPad-Emulator.git
   cd LD-ToyPad-Emulator

   printf '\necho "usbip-vudc.0" > UDC\nusbipd -D --device\nsleep 2;\nusbip attach -r debian -b usbip-vudc.0\nchmod a+rw /dev/hidg0' >> usb_setup_script.sh
   sudo curl https://raw.githubusercontent.com/virtualhere/script/main/install_server | sudo sh

   sudo cp usb_setup_script.sh /usr/local/bin/toypad_usb_setup.sh
   sudo chmod +x /usr/local/bin/toypad_usb_setup.sh
   (sudo crontab -l 2>/dev/null; echo "@reboot sudo /usr/local/bin/toypad_usb_setup.sh") | sudo crontab -
   ```

5. Reboot your device with this command:

   ```bash
   sudo shutdown -r now
   ```

6. Log in again and run the following commands in the terminal:

   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

   nvm install 11
   sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``
   npm install --global node-gyp@8.4.1
   npm config set node_gyp $(npm prefix -g)/lib/node_modules/node-gyp/bin/node-gyp.js

   cd LD-ToyPad-Emulator
   npm install
   ```

#### Usage

1. Start the virtual machine if it's not already running. Then start the **VirtualHere USB Client** and double click on `LEGO READER V2.10`.

2. Run the emulator server with this command if you are in the correct folder (otherwise run `cd LD-ToyPad-Emulator` first):

   ```bash
   npm run start
   ```

3. Type `http://debian` in a browser to use the emulator.

   If you want to turn it off, just press `Ctrl + C` in the terminal, then use the command `sudo shutdown now` to power off the virtual machine or just pause it from the host.

4. Finally, start your console emulator and the game itself (e.g. Cemu).

#

<hr>

### Option 2: Single Board Computer

#### Prerequisites

- One of the following supported devices:
  - **Raspberry Pi Zero W** (~$10)
  - **Raspberry Pi Zero 2 W** (~$15) ← recommended over the original Zero W
  - **Raspberry Pi 4 B** (requires a USB-C power splitter — search "USB-C PWR Splitter Raspberry Pi 4" on AliExpress or pishop.us)
  - **Raspberry Pi 5** (requires the same USB-C power splitter as the Pi 4)
  - > **NOTE**: Will NOT work with Raspberry Pi 2, 3, 3A, 3A+, 3B, or 3B+. These models cannot act as a USB gadget.
- **USB cable** that supports data transmission — micro-USB for the Zero/Zero 2 W, USB-C for the Pi 4/5 (a phone charging cable, not a charge-only cable)
- 2 GB+ Micro SD card
- Your PC and the Pi must both have an internet connection

#### Step 1 — Flash the OS

Flash **Raspberry Pi OS (Legacy, 32-bit) Lite** onto your SD card using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

> Lite is recommended for all Zero models as it is the lightest and most compatible option. Pi 4/5 users may use the 64-bit Lite image instead.

**Before flashing**, click the gear/settings icon in the Imager and configure:
- Hostname: `toypad`
- SSH enabled, with a username and password you will remember
- Your Wi-Fi network name and password

> Wi-Fi must be configured here because the USB port will be used for the gadget connection, not networking.

#### Step 2 — One-liner setup (recommended)

Connect your Pi to power, wait for it to boot, SSH in, then run:

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_FORK/LD-ToyPad-Emulator/master/setup.sh | bash
```

This automatically detects your hardware, installs everything, configures PS4/PS5 USB compatibility, sets up mDNS, and reboots. After reboot, the emulator is available at:

```
http://toypad.local
```

No port number required.

> Replace `YOUR_FORK` with your GitHub username.

#### Step 2 (manual) — Run these commands instead

If you prefer to set up manually:

**2a. USB gadget + dependencies:**

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_FORK/LD-ToyPad-Emulator/master/pi_setup.sh | bash
```

**2b. Reboot:**

```bash
sudo shutdown -r now
```

**2c. After reconnecting, verify the USB gadget is ready:**

```bash
ls /dev/hidg0
```

You must see `/dev/hidg0` before continuing. If it's missing, see [/dev/hidg0 is missing after reboot](#devhidg0-is-missing-after-reboot).

**2d. Pull the container image:**

Choose the correct platform for your device:

| Device | OS | Platform |
|---|---|---|
| Raspberry Pi Zero W | 32-bit Legacy Lite | `linux/arm/v6` |
| Raspberry Pi Zero 2 W | 32-bit Legacy Lite | `linux/arm/v7` |
| Raspberry Pi 4 / 5 | 64-bit Lite | `linux/arm64` |
| x86-64 PC | Any | `linux/amd64` |

```bash
podman pull --platform=linux/arm/v7 ghcr.io/berny23/ld-toypad-emulator:latest
```

> **Pi Zero 2 W on 32-bit OS**: if the pull fails with `no image found for architecture arm, variant "v7"`, pull by digest instead. Find the armv7 digest on the [package registry](../../pkgs/container/ld-toypad-emulator) under the **OS / Arch** tab:
> ```bash
> podman pull ghcr.io/berny23/ld-toypad-emulator:latest@sha256:<digest>
> ```

**2e. Create the container:**

```bash
podman create \
  --name ld-toypad-emulator \
  -p 80:80 \
  --device /dev/hidg0:/dev/hidg0 \
  -v ~/LD-ToyPad-Emulator/server/images:/app/server/images:Z \
  -v ~/LD-ToyPad-Emulator/server/index.html:/app/server/index.html:Z \
  -v ~/LD-ToyPad-Emulator/server/stylesheets/main.css:/app/server/stylesheets/main.css:Z \
  -v ~/LD-ToyPad-Emulator/server/scripts/main.js:/app/server/scripts/main.js:Z \
  ghcr.io/berny23/ld-toypad-emulator:latest
```

**2f. Start it:**

```bash
podman start ld-toypad-emulator
```

**2g. (Optional) Auto-start on boot:**

```bash
(crontab -l 2>/dev/null; echo "@reboot sleep 12 && podman start ld-toypad-emulator") | crontab -
```

**2h. (Optional) mDNS for `http://toypad.local`:**

```bash
sudo apt install -y avahi-daemon
sudo systemctl enable --now avahi-daemon
```

After this, open `http://toypad.local` in any browser on your network — no IP address or port number needed.

#### Usage

Open a browser on any device on your network and go to:

```
http://toypad.local
```

or `http://<your-pi-ip>` if mDNS is not set up.

To stop the emulator:

```bash
podman stop ld-toypad-emulator
sudo shutdown now
```

## Keyboard Shortcuts

The emulator supports keyboard shortcuts for placing and removing tokens without using the mouse — useful while gaming.

| Key | Action |
|---|---|
| Click a token | Select it (it glows yellow) |
| `1` – `7` | Place selected token on that pad slot / return occupying token to Toy Box |
| `0` | Deselect |

Click the **⌨ Keys** button in the top-right corner of the UI for a full layout reference.

## Custom Images

Place PNG files in `server/images/` on your Pi (the folder is mounted into the container). Name them by character or vehicle ID:

- `1.png` — primary image for character/vehicle ID 1
- `1_1.png`, `1_2.png` — alternate images that cycle automatically every 20 seconds

Character IDs: [charactermap.json](server/json/charactermap.json)  
Vehicle IDs: [tokenmap.json](server/json/tokenmap.json)

## Update

```bash
podman stop ld-toypad-emulator
podman rm ld-toypad-emulator
podman image rm ghcr.io/berny23/ld-toypad-emulator:latest
```

Then re-pull and re-create the container starting from Step 2d above.

## Troubleshooting

### PS4 / PS5 not detecting the Toy Pad

This is most commonly caused by missing USB descriptor fields in the gadget setup script. The fix is included in `usb_setup_script.sh` from v1.5.0 onwards. If you are on an older setup, replace `/usr/local/bin/toypad_usb_setup.sh` with the updated version from this repo and reboot.

If using the original setup script, add these lines after the `mkdir g1 / cd g1` block:

```bash
echo "0x0200" > bcdUSB
echo "0x0100" > bcdDevice
echo "0x00"   > bDeviceClass
echo "0x00"   > bDeviceSubClass
echo "0x00"   > bDeviceProtocol
```

And after `mkdir configs/c.1`:

```bash
echo "0x80" > configs/c.1/bmAttributes
echo "250"  > configs/c.1/MaxPower
```

Then replace the final `sleep 3` with `sleep 5` and reboot.

### /dev/hidg0 is missing after reboot

Run the setup script manually to see any errors:

```bash
sudo /usr/local/bin/toypad_usb_setup.sh
```

Verify `dwc2` is in the correct boot config file:

```bash
# Bookworm and newer:
grep dwc2 /boot/firmware/config.txt

# Legacy (Bullseye and older):
grep dwc2 /boot/config.txt
```

If missing, add it and reboot:

```bash
# Bookworm and newer:
echo "dtoverlay=dwc2" | sudo tee -a /boot/firmware/config.txt
```

### Light effects not working

The pad slot colours are driven by socket events from the game (`Fade One`, `Fade All`, `Color One`, `Color All`). If the status warning has disappeared (i.e. the game has connected), the effects should work. If slots are not changing colour, try clicking **Sync** in the UI.

### RPCS3 cannot detect the Toy Pad

**This solution works only for RPCS3 and will break Toy Pad detection with every other emulator!**

Download and run [Zadig](https://zadig.akeo.ie). Click on `Options` and tick `List All Devices`. Select `LEGO READER V2.10`, select `WinUSB`, click `Replace Driver` and confirm. Restart RPCS3.

To undo: open Device Manager → USB devices → `LEGO READER V2.10` → Driver tab → Previous Driver.

**Linux:** move `99-dimensions.rules` from the server folder to `/etc/udev/rules.d/` and reboot.

### Webpage not reachable (Oracle VirtualBox)

Shutdown your VM. In VirtualBox manager, open Settings → Network → change `Attached to` to `Bridged Adapter`. Start the VM.

### Webpage not reachable (VMware)

Shutdown your VM. Right-click the VM → Settings → Network Adapter → select `Bridged`. Start the VM.

### Error: listen EADDRINUSE: address already in use :::80

Another process is using port 80. Either stop it, or edit the last line of `index.js` to use a different port and append that port to the browser URL (e.g. `http://toypad.local:8081`).

### VirtualHere USB Client doesn't show LEGO READER V2.10

The VM hostname must be set to `debian`. Alternatively, replace `YOUR_IP_ADDRESS` in this command with your VM's IP (`hostname -I`) and run it inside the `LD-ToyPad-Emulator` folder:

```bash
git reset --hard ; printf '\necho "usbip-vudc.0" > UDC\nusbipd -D --device\nsleep 2;\nusbip attach -r YOUR_IP_ADDRESS -b usbip-vudc.0\nchmod a+rw /dev/hidg0' >> usb_setup_script.sh ; sudo cp usb_setup_script.sh /usr/local/bin/toypad_usb_setup.sh
```

## Acknowledgements

- **ags131** for writing one of the main NodeJS libraries used: [https://www.npmjs.com/package/node-ld](https://www.npmjs.com/package/node-ld)
- **cort1237** for implementing vehicle upgrade persistence and UI updates
- **benlucaslaws** for the filtering system for vehicle/character abilities and game worlds
- **DaPiMan** for vehicle ID corrections and other improvements
- **Euniemeansme** for character/vehicle ability data improvements
- **VladimirKuletski** for CI workflow automation
- **Glitxh** for the v1.5.0 UI overhaul, dark mode, keyboard shortcuts, image cycling, and PS4/PS5 USB compatibility fix

## License

[MIT](https://choosealicense.com/licenses/mit/)
