# Linux on the Thinkpad X1 Carbon 6th
## About this document
I'm here collecting some of the configuration tweaks I did to setup Linux on my Thinkpad X1 Carbon 6th. Most things work out of the box after installing [Xubuntu](https://xubuntu.org/), but there are some exceptions. Another excellent document which also works well for Xubuntu on the TXC6 is the [Arch Linux guide](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)).

## The system
```bash
$ sudo dmidecode -s system-version
ThinkPad X1 Carbon 6th
```

## Crucial BIOS firmware update
The BIOS of the machine needs to be updated, because unfortunately, the manufacturer has removed support for suspend to RAM support (aka S3 deep sleep). Instead the TX1C6 supports a new macish sleep mode (where the system can be woken up anytime by software), but the Linux kernel does not to my understanding support it yet. Lenovo later issued a BIOS update for the TX1C6, allowing the use of S3.

First confirm that you need the update (do you see S3 in the list? If not, then you need to update to use S3):

```bash
$ dmesg | grep -i "acpi: (supports"
```

1. Enter bios and change "UEFI/Legacy boot" to "Both" (default is "legacy", which will prevent update of BIOS).
2. Download the right ISO at [support.lenovo.com](https://support.lenovo.com)
3. Copy to a USB stick:
```bash
 dd if=image.img of=/dev/sdX bs=1M
```
4. Reboot to see it finds the USB stick and follow instructions (you might need to press F12 during boot).
5. Enter BIOS settings again, go into the power menu, and change "Sleep state" to "Linux"
6. Reboot to Linux and hopefully it shows:
```bash
$ dmesg | grep -i "acpi: (supports"
ACPI: (supports S0 S3 S4 S5)
```
