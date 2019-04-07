# Linux on the Thinkpad X1 Carbon 6th
## About this document
In this document I'm collecting some of the configuration tweaks I did to setup Linux on my Thinkpad X1 Carbon 6th - primarily so that I can repeat them quickly in case I need to reinstall. The good news is that most things work out of the box after installing [Xubuntu](https://xubuntu.org/), but there are some exceptions. (In fact more things seem to work out of the box with Xubuntu compared with regular Ubuntu on the TX1C6.) Another excellent document which also works well for Xubuntu on the TX1C6 is the [Arch Linux guide](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)).

- <p.oscar.franzen@gmail.com>

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

## Get the Touchpad to function
This one is annoying because the system loads into X11 and without a mouse I found it difficult to open a terminal window. I used a USB-connected mouse to open a terminal window.

1. Uncomment the `i2c_i801` module in `/etc/modprobe.d/blacklist.conf`
2. Add `psmouse.synaptics_intertouch=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`
3. `sudo update-grub`
4. Reboot

## External Mac keyboard
I still like and use a Mac keyboard with the TX1C6. Some tweaking is needed for a good experience.

1. Clone this repo: [hid-apple-patched](https://github.com/free5lot/hid-apple-patched)
```bash
git clone https://github.com/free5lot/hid-apple-patched
```
2. Go to the source directory and run
```bash
sudo apt install dkms
sudo dkms add .
sudo dkms build hid-apple/1.0
sudo dkms install hid-apple/1.0
```

3. Choose settings by editing:
```
sudo vim /etc/modprobe.d/hid_apple.conf
```
I use:
```
$ cat /etc/modprobe.d/hid_apple.conf
options hid_apple swap_opt_cmd=1             # Swap the Option ("Alt") and Command ("Flag") keys 
options hid_apple ejectcd_as_delete=1        # Use Eject-CD key as Delete
options hid_apple fnmode=2                   # Mode of top-row keys should be normal function keys (not media keys)
```
5. Apply
```bash
sudo update-initramfs -u
```

## Annoying screen flickering
To get rid of the annoying screen flickering, for example when browsing, the following worked for me:

1. Create another X11 config file:
```bash
sudo vim /usr/share/X11/xorg.conf.d/20-intel_flicker_fix.conf
```

Add the following lines:
```bash
Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
  Option      "TripleBuffer" "true"
  Option      "TearFree"     "true"
EndSection
```

2. Reboot / Restart X11

## Disable capslock
Many times I hit capslock by accident so I prefer to have it disabled. It can be achieved by:
```bash
setxkbmap -option 'ctrl:nocaps'
```

1. When the computer wakes up from sleep, capslock activates again. A more permanent solution would be to:

Create a small helper script and place it anywhere.
```bash
#!/bin/bash

# if capslock is not activated
if [[ `xset q | grep -P 'Caps Lock:.+?on'` == "" ]]; then
	# disable capslock
	((/usr/bin/setxkbmap -option 'ctrl:nocaps') 2>&1) > /dev/null
fi
```
Make it executable:
```bash
chmod +x script
```

3. Create a new file:
```bash
sudo vim /usr/lib/pm-utils/sleep.d/99ZZ_disable_capslock
```

And add the following lines:
```bash
#!/bin/sh

case "$1" in
    resume)
        /path/to/helper/script
esac
```

## Changing shortcut keys for `xfce4-terminal`
I prefer to be able to open a new terminal tab with `ctrl+t` and close a tab with `ctrl+w`. Fortunately this is easy to fix:
1. Fire ```vim /home/rand/.config/xfce4/terminal/accels.scm```
2. Then add
```
(gtk_accel_path "<Actions>/terminal-window/close-tab" "<Primary>w")
(gtk_accel_path "<Actions>/terminal-window/new-tab" "<Primary>t")
```

## Screenshot selection
I like to be able to press a keyboard combination and then being able to select an area for screenshots.

1. Install scrot
```bash
sudo apt install scrot
```

2. Create a helper script and put it wherever you like:
```bash
#!/bin/bash
sleep 0.5
/usr/bin/scrot -s
```

3. Make it executable
```bash
chmod +x name.sh
```

4. In Xfce4, go to settings -> Keyboard -> Application shortcuts and add the helper script.

## Timemachine-like backups
Here is a good script for making backups like timemachine: https://github.com/laurent22/rsync-time-backup

## Mount an iPhone
iPhones can easily be mounted. First install:

```
sudo apt install libimobiledevice-utils
```

Then run:

```bash
idevicepair validate
idevicepair pair
ifuse ~/Temp
cd ~/Temp
ls

# unmount when done
fusermount -u ~/Temp

```
