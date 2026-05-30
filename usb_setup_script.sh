#!/bin/bash

# Created by ags131
# PS4/PS5 compatibility fixes by Glitxh:
#   - Added bcdUSB, bcdDevice (PS4 requires explicit USB 2.0 declaration)
#   - Added bmAttributes + MaxPower (required for strict USB hosts)
#   - Increased pre-UDC sleep for stability on faster SBCs (Zero 2 W etc.)

cd /sys/kernel/config/usb_gadget
mkdir -p g1
cd g1

# Device descriptor
echo "0x0E6F" > idVendor          # PDP
echo "0x0241" > idProduct          # LEGO READER V2.10
echo "0x0200" > bcdUSB             # USB 2.0 — required by PS4/PS5
echo "0x0100" > bcdDevice          # Device version 1.0
echo "0x00"   > bDeviceClass
echo "0x00"   > bDeviceSubClass
echo "0x00"   > bDeviceProtocol

mkdir -p strings/0x409
echo "P.D.P.000000"   > strings/0x409/serialnumber
echo "PDP LIMITED. "  > strings/0x409/manufacturer
echo "LEGO READER V2.10" > strings/0x409/product

# HID function
mkdir -p functions/hid.g0
echo 32 > functions/hid.g0/report_length
echo -ne "\x06\x00\xFF\x09\x01\xA1\x01\x19\x01\x29\x20\x15\x00\x26\xFF\x00\x75\x08\x95\x20\x81\x00\x19\x01\x29\x20\x91\x00\xC0" > functions/hid.g0/report_desc

# Configuration descriptor
mkdir -p configs/c.1
mkdir -p configs/c.1/strings/0x409
echo "LEGO READER V2.10" > configs/c.1/strings/0x409/configuration
echo "0x80" > configs/c.1/bmAttributes  # Bus powered (required for PS4)
echo "250"  > configs/c.1/MaxPower       # 500 mA

ln -sf functions/hid.g0/ configs/c.1/

UDC=$(ls /sys/class/udc)
# Give the gadget stack time to finish before writing the UDC.
# Increased to 5s for Bookworm on Zero 2 W — do not reduce.
sleep 5;
