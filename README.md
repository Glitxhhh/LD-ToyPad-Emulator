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
- Can be configured easily by following the instructions below

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
  - **Raspberry Pi 4 B** (requires a `USB/Power Splitter` — search "USB-C PWR Splitter Raspberry Pi 4" on AliExpress or pishop.us)
  - **Raspberry Pi 5** (requires the same USB-C power splitter as the Pi 4)
  - > **NOTE**: Will NOT work with Raspberry Pi 2, 3, 3A, 3A+, 3B, or 3B+. These models cannot act as a USB gadget.
- **USB cable** that supports data transmission — micro-USB for the Zero/Zero 2 W, USB-C for the Pi 4/5 (e.g. a phone charging cable that isn't charge-only)
- 2 GB+ Micro SD card
- Your PC and the Pi must both have an internet connection

#### Step 1 — Flash the OS

Flash **Raspberry Pi OS (Legacy, 32-bit) Lite** onto your SD card using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

> The Legacy Lite image is recommended for all Zero models as it is the lightest and most compatible option. Pi 4/5 users may use the 64-bit Lite image instead.

**Before flashing**, click the settings/gear icon in the Imager and configure:
- A hostname (e.g. `toypad`)
- SSH enabled, with a username and password you will remember
- Your Wi-Fi network name and password

> Wi-Fi must be configured here because the USB port will be used for the gadget connection, not networking.

#### Step 2 — Connect and SSH in

Insert the SD card and connect your Pi to your PC via USB cable.

> **Pi Zero / Zero 2 W**: use the **inner** micro-USB port (labelled "USB"), **not** the port on the edge of the board (that one is power-only).

Find your Pi's IP address using a tool like [Advanced IP Scanner](https://www.advanced-ip-scanner.com/) or check your router's device list, then SSH in:

```bash
ssh yourusername@<your-pi-ip>
```

#### Step 3 — Run the setup script

This configures your Pi as a USB gadget and installs the required dependencies (including Podman):

```bash
curl -sSL https://raw.githubusercontent.com/Berny23/LD-ToyPad-Emulator/master/pi_setup.sh | bash
```

#### Step 4 — Reboot

```bash
sudo shutdown -r now
```

#### Step 5 — Verify the USB gadget is ready

After reconnecting via SSH, confirm that the HID gadget device was created successfully:

```bash
ls /dev/hidg0
```

You should see `/dev/hidg0` printed back. **Do not proceed until this works** — if it's missing, see the [troubleshooting section](#dev-hidg0-is-missing-after-reboot).

#### Step 6 — Pull the container image

Choose the correct platform for your device and OS from the table below. You can also check the [package registry](../../pkgs/container/ld-toypad-emulator) for all available images.

| Device | OS | Platform |
|---|---|---|
| Raspberry Pi Zero W | 32-bit (Legacy Lite) | `linux/arm/v6` |
| Raspberry Pi Zero 2 W | 32-bit (Legacy Lite) | `linux/arm/v7` |
| Raspberry Pi 4 / 5 | 64-bit Lite | `linux/arm64` |
| x86-64 PC | Any | `linux/amd64` |

```bash
podman pull --platform=linux/arm/v7 ghcr.io/berny23/ld-toypad-emulator:latest
```

> Replace `linux/arm/v7` with the correct platform for your device from the table above.

> **Note for Raspberry Pi Zero 2 W users on 32-bit OS**: if the pull fails with `no image found for architecture arm, variant "v7"`, pull by digest instead. Find the correct digest for your platform on the [package registry page](../../pkgs/container/ld-toypad-emulator) under the **OS / Arch** tab, then run:
> ```bash
> podman pull ghcr.io/berny23/ld-toypad-emulator:latest@sha256:<digest>
> ```

#### Step 7 — Create the container

```bash
podman create \
  --name ld-toypad-emulator \
  -p 8080:80 \
  --device /dev/hidg0:/dev/hidg0 \
  ghcr.io/berny23/ld-toypad-emulator:latest
```

> If you pulled by digest in the previous step, replace `ghcr.io/berny23/ld-toypad-emulator:latest` with `ghcr.io/berny23/ld-toypad-emulator:latest@sha256:<digest>`.

#### Step 8 — Start the container

```bash
podman start ld-toypad-emulator
```

Verify it's running and check for errors:

```bash
podman ps
podman logs ld-toypad-emulator
```

#### Step 9 — (Optional) Auto-start on boot

To have the emulator start automatically every time your Pi powers on, add a cron entry:

```bash
(crontab -l 2>/dev/null; echo "@reboot sleep 10 && podman start ld-toypad-emulator") | crontab -
```

The `sleep 10` gives the USB gadget setup time to finish creating `/dev/hidg0` before the container starts.

#### Usage

Open a browser on any device on your network and go to:

```
http://<your-pi-ip>:8080
```

To stop the emulator:

```bash
podman stop ld-toypad-emulator
sudo shutdown now
```

## Update

To update this software, run the following commands:

```bash
podman stop ld-toypad-emulator
podman rm ld-toypad-emulator
podman image rm ghcr.io/berny23/ld-toypad-emulator:latest
```

Then re-pull and re-create the container starting from [Step 6](#step-6--pull-the-container-image) above.

## Adding Images

If you would like your tags to have custom images over them to personalize your experience, name your image `(ID).png` and place it in `server/images` inside the Toypad Emulator folder. If you want the image to cover the entirety of the tag with no blank space, make sure it is either 100x100 pixels or can be scaled to that size.

Character IDs can be found [here](https://github.com/Berny23/LD-ToyPad-Emulator/blob/master/server/json/charactermap.json)

Vehicle IDs can be found [here](https://github.com/Berny23/LD-ToyPad-Emulator/blob/master/server/json/tokenmap.json)

## Troubleshooting

### /dev/hidg0 is missing after reboot

This means the USB gadget setup script did not run successfully. Try running it manually to see any errors:

```bash
sudo /usr/local/bin/toypad_usb_setup.sh
```

Also verify the `dwc2` overlay is in the correct boot config file for your OS:

```bash
# Bookworm and newer:
grep dwc2 /boot/firmware/config.txt

# Legacy (Bullseye and older):
grep dwc2 /boot/config.txt
```

If the line is missing, add it to the correct file and reboot:

```bash
# Bookworm and newer:
echo "dtoverlay=dwc2" | sudo tee -a /boot/firmware/config.txt

# Legacy:
echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
```

### RPCS3 cannot detect the Toy Pad

**This solution works only for RPCS3 and will break Toy Pad detection with every other emulator!**

Download and run [Zadig](https://zadig.akeo.ie).

Click on `Options` and tick `List All Devices`. Select `LEGO READER V2.10` in the dropdown menu, then select `WinUSB` if it's not already selected, click on the `Replace Driver` button and on `Yes` in the dialog.

After the installation has finished, exit Zadig and restart RPCS3. If you get stuck on the main menu, just close the game, right-click on it in the RPCS3 games list, select `Change Custom Configuration`, switch to the `Network` tab and choose `Disconnected` in both drop-down menus. The game will now correctly detect the Toy Pad.

To undo the changes from Zadig, you have to rollback the driver:

1. Open `Device Manager`, scroll down to `USB devices` and expand the section.
2. Double-click `LEGO READER V2.10`.
3. Switch to the `Driver` tab, click `Previous Driver`, select the first option and click yes.

**Solution for Linux systems**

In order to fix this, you will need to add a custom udev rule in your system, so the software can communicate with the game. The udev rule is in the root of the server folder. (thanks to wof for sharing the rule).

To add the rule, simply just move the `99-dimensions.rules` file to `/etc/udev/rules.d/` (a reboot might be required).

If moving the file is not allowed, just open a terminal inside the `rules.d` folder and run this command: `sudo nano 99-dimensions.rule`, open the rule file in the server root in a text editor, copy the contents and paste it in the terminal then press Ctrl + X to save the file.

### Webpage not reachable (Oracle VirtualBox)

Shutdown your virtual machine (icon in the upper right corner). In VirtualBox's manager, click your image and open `Settings`. Under `Network` change `Attached to:` to `Bridged Adapter` and click `ok`. Start your virtual machine.

### Webpage not reachable (VMware)

Shutdown your virtual machine (icon in the upper right corner). Right-click on your virtual machine's name in VMware Workstation or VMware Player and click `Settings...`. Click on `Network Adapter` and select `Bridged`. Click `OK` and start your virtual machine.

### Error: listen EADDRINUSE: address already in use :::80

Either close any other software that is using port 80 or manually edit the last line of index.js (with `nano index.js`, edit the line, then press `Ctrl + O`, `Enter` and `Ctrl + X`).

If you did this, you may need to append your selected port to the address in the browser (like `http://debian:500` or `http://192.168.0.165:500` if your port is 500).

### VirtualHere USB Client doesn't show LEGO READER V2.10

When installing the virtual machine, you have to set the hostname to `debian`.

Alternatively, copy the following command and replace `YOUR_IP_ADDRESS` with your virtual machine's IP address (it looks like `192.168.X.X`, run `hostname -I` to show it). After you've done this, run the modified command while you're inside the `LD-ToyPad-Emulator` folder.

```bash
git reset --hard ; printf '\necho "usbip-vudc.0" > UDC\nusbipd -D --device\nsleep 2;\nusbip attach -r YOUR_IP_ADDRESS -b usbip-vudc.0\nchmod a+rw /dev/hidg0' >> usb_setup_script.sh ; sudo cp usb_setup_script.sh /usr/local/bin/toypad_usb_setup.sh
```

### VirtualHere shows LEGO READER V2.10, but fails with "Operation not permitted"

When double clicking on "LEGO READER V2.10", if it returns `Error "Operation not permitted" (-1) trying to use this device.`. Try these steps:

1. Right click the device in the VirtualHere Client and select "Custom Event Handler..."
2. Add `onReset.$VENDOR_ID$.$PRODUCT_ID$=`

Then try using the device again.

### Webpage not reachable under http://debian/

If you're using a virtual machine, make sure you've applied the solution specific to your software first ([VirtualBox](#webpage-not-reachable-oracle-virtualbox) or [VMware](#webpage-not-reachable-vmware))!

After that, run the command `hostname -I` in your virtual machine (or on your single board computer) and type the IP address that looks like `192.168.X.X` in your webbrowser.

## Acknowledgements

- **ags131** for writing one of the main NodeJS libraries I'm using: [https://www.npmjs.com/package/node-ld](https://www.npmjs.com/package/node-ld). My project would've been impossible to create without this guy's research.
- **cort1237** for implementing writing data (like vehicle upgrades) to toy tags, as well as several user interface updates and support for saving toy tags locally.
- **benlucaslaws** for improving the user experience and implementing a complete filtering system for vehicle/character abilities and game worlds.
- **DaPiMan** for helping with missing or misplaced vehicle IDs and other improvements.
- **Euniemeansme** for adding/fixing character and vehicle abilities and other data improvements.
- **VladimirKuletski** for creating/updating CI workflows for automated testing via GitHub Actions.

## License

[MIT](https://choosealicense.com/licenses/mit/)
