# Linux on the ThinkPad X1 Carbon 6th
## About this document
In this document I'm collecting some configurations I did to setup Linux on my ThinkPad X1 Carbon 6th - primarily so that I can repeat them quickly in case I need to reinstall; I'm also including some general configuration that is not specific for the Thinkpad (postfix, etc).

Back to the Thinkpad - the good news is that most things work out of the box after installing [Xubuntu](https://xubuntu.org/) bionic, but there are some exceptions. (In fact more things seem to work out of the box with Xubuntu compared with regular Ubuntu on the TX1C6.) Another excellent document which also works well for Xubuntu on the TX1C6 is the [Arch Linux guide](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)). At the moment this document has evolved to a general set of notes for quick reference.

- Oscar <p.oscar.franzen@gmail.com>

## Why I run Linux on the ThinkPad
I was a Linux user for a number of years, then 2011 turned to Mac, and finally in 2018 went back to Linux because I'm  concerned with the lack of privacy and freedom with being locked into Apple products.

## The system
```bash
$ sudo dmidecode -s system-version
ThinkPad X1 Carbon 6th

$ uname -a | cut -d ' ' -f 3
5.3.6-050306-generic
```

### Hardware
```bash
$ lspci   
00:00.0 Host bridge: Intel Corporation Xeon E3-1200 v6/7th Gen Core Processor Host Bridge/DRAM Registers (rev 08)
00:02.0 VGA compatible controller: Intel Corporation UHD Graphics 620 (rev 07)
00:04.0 Signal processing controller: Intel Corporation Xeon E3-1200 v5/E3-1500 v5/6th Gen Core Processor Thermal Subsystem (rev 08)
00:08.0 System peripheral: Intel Corporation Xeon E3-1200 v5/v6 / E3-1500 v5 / 6th/7th Gen Core Processor Gaussian Mixture Model
00:14.0 USB controller: Intel Corporation Sunrise Point-LP USB 3.0 xHCI Controller (rev 21)
00:14.2 Signal processing controller: Intel Corporation Sunrise Point-LP Thermal subsystem (rev 21)
00:16.0 Communication controller: Intel Corporation Sunrise Point-LP CSME HECI #1 (rev 21)
00:1c.0 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express Root Port #1 (rev f1)
00:1c.4 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express Root Port #5 (rev f1)
00:1d.0 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express Root Port #9 (rev f1)
00:1f.0 ISA bridge: Intel Corporation Sunrise Point LPC Controller/eSPI Controller (rev 21)
00:1f.2 Memory controller: Intel Corporation Sunrise Point-LP PMC (rev 21)
00:1f.3 Audio device: Intel Corporation Sunrise Point-LP HD Audio (rev 21)
00:1f.4 SMBus: Intel Corporation Sunrise Point-LP SMBus (rev 21)
00:1f.6 Ethernet controller: Intel Corporation Ethernet Connection (4) I219-V (rev 21)
02:00.0 Network controller: Intel Corporation Wireless 8265 / 8275 (rev 78)
04:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd NVMe SSD Controller SM981/PM981/PM983
05:00.0 PCI bridge: Intel Corporation JHL6540 Thunderbolt 3 Bridge (C step) [Alpine Ridge 4C 2016] (rev 02)
06:00.0 PCI bridge: Intel Corporation JHL6540 Thunderbolt 3 Bridge (C step) [Alpine Ridge 4C 2016] (rev 02)
06:01.0 PCI bridge: Intel Corporation JHL6540 Thunderbolt 3 Bridge (C step) [Alpine Ridge 4C 2016] (rev 02)
06:02.0 PCI bridge: Intel Corporation JHL6540 Thunderbolt 3 Bridge (C step) [Alpine Ridge 4C 2016] (rev 02)
06:04.0 PCI bridge: Intel Corporation JHL6540 Thunderbolt 3 Bridge (C step) [Alpine Ridge 4C 2016] (rev 02)
3b:00.0 USB controller: Intel Corporation JHL6540 Thunderbolt 3 USB Controller (C step) [Alpine Ridge 4C 2016] (rev 02)
```

### Non-fixable problems
* The screen has one dead pixel

### Intermittent wifi issues
* https://askubuntu.com/questions/616119/unstable-wireless-with-intel-7260-iwlwifi-after-upgrade-to-15-04
```bash

# Add the below line to /etc/modprobe.d/iwlwifi.conf
options iwlwifi 11n_disable=8 power_save=0 swcrypto=1

sudo modprobe -r iwlmvm
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi

# confirm the option is loaded
modinfo iwlwifi
```

## TODO
* Check BIOS setting for powersaving for Thunderbolt 3

## Plain text login
I like being greeted by the plain cold login prompt and running `startx` to fire up X. I prefer not to use ligthDM, gdm3, etc. In `/etc/default/grub`, make sure "quiet splash" is replaced with "text" in the `GRUB_CMDLINE_LINUX_DEFAULT`. Then run `sudo update-grub`.

Make sure to also disable lightdm (if that is what you run as login manager):

```bash
sudo systemctl disable lightdm
```

## Crucial BIOS firmware update
The BIOS of the machine needs to be updated to version 1.30, because unfortunately, Lenovo has removed support for suspend to RAM support (aka S3 deep sleep). Instead the TX1C6 supports a new macish sleep mode (where the system can be woken up anytime by software) called Windows Modern Standby mode, but the Linux kernel does not support it yet. Lenovo later issued a BIOS update for the TX1C6, allowing the use of S3.

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

Try that it works
```
systemctl suspend
```

## Get the Touchpad to function
This one is annoying because the system loads into X11 and without a mouse I found it difficult to open a terminal window. I used a USB-connected mouse to open a terminal window.

1. Uncomment the `i2c_i801` module in `/etc/modprobe.d/blacklist.conf`
2. Add `psmouse.synaptics_intertouch=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`
3. `sudo update-grub`
4. Reboot

## Troubleshoot keyboard layout
```
$ setxkbmap -print
xkb_keymap {
	xkb_keycodes  { include "evdev+aliases(qwerty)"	};
	xkb_types     { include "complete"	};
	xkb_compat    { include "complete"	};
	xkb_symbols   { include "pc+se+inet(evdev)+ctrl(nocaps)"	};
	xkb_geometry  { include "pc(pc105)"	};
};

```

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

### Fix "pipe" problem on the Swedish Apple USB keyboard
The pipe character is incorrectly mapped (mine was `alt+§`). Create a small helper script and make it executable `chmod +x helper.sh` and put it somewhere, and add it in Xfce4 (go to settings, Session and Startup, Application Autostart).
```bash
#!/bin/bash

if [[ `xinput -list | grep Apple` != "" ]]; then
  setxkbmap -device `xinput -list | grep Apple | sed 's/.*id=\(.*\)\t.*/\1/'` -layout se
  setxkbmap -device `xinput -list | grep Apple | sed 's/.*id=\(.*\)\t.*/\1/'` -option apple:badmap
else
    # if the apple keyboard is not connected
    setxkbmap -device `xinput -list | grep 'AT Translated Set 2 keyboard' | sed 's/.*id=\(.*\)\t.*/\1/'` -layout se
fi
```

## Annoying screen flickering
To get rid of screen flickering when scrolling, the following might work:

1. Create another X11 config file:
```bash
sudo vim /etc/X11/xorg.conf.d/20-intel-graphics.conf
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

# Enable capslock again
#setxkbmap -option
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
sudo vim /lib/systemd/system-sleep/disable_capslock
```

And add the following lines:
```bash
#!/bin/bash

sleep 1s
/path/to/helper/script
```

Make it executable
```
sudo chmod +x /lib/systemd/system-sleep/disable_capslock
```

## xfce4-terminal
### Changing shortcut keys for `xfce4-terminal`
I prefer to be able to open a new terminal tab with `ctrl+t` and close a tab with `ctrl+w`. Fortunately this is easy to fix:
1. Fire ```vim /home/rand/.config/xfce4/terminal/accels.scm```
2. Then add
```
(gtk_accel_path "<Actions>/terminal-window/close-tab" "<Primary>w")
(gtk_accel_path "<Actions>/terminal-window/new-tab" "<Primary>t")
(gtk_accel_path "<Actions>/terminal-window/search" "<Shift><Alt>f")
```
### Prevent `ctrl+c` hickups (I prefer to have ctrl+c to cancel a command, not copy text)
- Delete all default keyboard shortcuts in Xfce4 settings.

- Make sure this is commented out:
```
; (gtk_accel_path "<Actions>/terminal-window/copy" "<Primary>c")
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

Identify the UUID of the external backup disk
```
sudo blkid
```

Create a small helper script and put it somewhere (`/home/foobar` is the directory to be backed up and `/mount/point/of/backup` is the mounted external drive; `.exclude_backup_patterns` contains optional directories to be excluded, one directory path per line). I removed the default rsync `--perm` option to preserve permissions, because if I have a directory set to -rw, this directory cannot be deleted by rsync.

```bash
#!/bin/bash

if [ -e /dev/disk/by-uuid/UUID ]; then
  /path/to/rsync_tmbackup.sh --rsync-set-flags "-D --compress \
  --numeric-ids --links --hard-links --one-file-system --itemize-changes --times \
  --recursive --owner --group --stats --human-readable --chmod=ugo=rw" --no-auto-expire \
    /home/foobar /mount/point/of/backup .exclude_backup_patterns
else
  echo "backup drive not found"
fi
```

A good idea is to use crontab to launch the backup every day at a certain time:

```bash
crontab -e
```

The following line will run the backup at 19:00 every day (don't forget to add two empty lines to the end of the crontab file):

```
0 19 * * * /path/to/helper/script
```

## Mount an iPhone
iPhones can easily be mounted. First install:

```
sudo apt install libimobiledevice-utils
sudo apt install ifuse
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
## Improving battery life
Following suggestion from https://medium.com/@hkdb/ubuntu-18-04-on-lenovo-x1-carbon-6g-d99d5667d4d5.

```
sudo apt-get install tlp tlp-rdw acpi-call-dkms tp-smapi-dkms acpi-call-dkms acpitool
```

### Lenovo throttling script
* https://github.com/erpalma/throttled

```
sudo apt install git virtualenv build-essential python3-dev libdbus-glib-1-dev libgirepository1.0-dev libcairo2-dev python3-venv

git clone https://github.com/erpalma/lenovo-throttling-fix.git

sudo ./install.sh
```
Enable it:
```
sudo systemctl enable --now lenovo_fix.service
```

### Disable Memory card slot, Fingerprint reader and WWAN (3G/4G) in BIOS
One [blogpost](https://jonfriesen.ca/blog/lenovo-x1-carbon-and-ubuntu-18.04/) recommends disabling these (the first two don't have Linux support anyway).

Reboot and enter BIOS settings and change to:
```
Security -> I/O Post Access -> Memory Card Slot -> Disabled
Security -> I/O Post Access -> Fingerprint reader -> Disabled
Security -> I/O Post Access -> Wireless WAN -> Disabled

# I also disabled NFC (Near Field Communication for some devices), because I don't know what I would use it for
Security -> I/O Post Access -> NFC Device -> Disabled
```

### Enable Framebuffer compression
According to [here](https://www.thinkwiki.org/wiki/X1_Linux_Tweaks) and [here](https://wiki.archlinux.org/index.php/Intel_graphics#Framebuffer_compression_(enable_fbc)), this is supposed to improve battery life. Add `i915.enable_fbc=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psmouse.synaptics_intertouch=1 i915.enable_fbc=1"
```
Update grub:
```
sudo update-grub
```

However, `dmesg` not shows this message and I don't know if this is good or not.

```
Setting dangerous option enable_fbc - tainting kernel
```

## Block facebook, twitter, etc
```
sudo vim /etc/hosts
```

Lines to add:
```
127.0.0.1   www.facebook.com
127.0.0.1   facebook.com
127.0.0.1   login.facebook.com
127.0.0.1   www.login.facebook.com
127.0.0.1   fbcdn.net
127.0.0.1   www.fbcdn.net
127.0.0.1   fbcdn.com
127.0.0.1   www.fbcdn.com
127.0.0.1   static.ak.fbcdn.net
127.0.0.1   static.ak.connect.facebook.com
127.0.0.1   connect.facebook.net
127.0.0.1   www.connect.facebook.net
127.0.0.1   www.twitter.com
127.0.0.1   twitter.com
127.0.0.1   apps.facebook.com
127.0.0.1   m.facebook.com
127.0.0.1   developers.facebook.com
127.0.0.1  dev.facebook.com
127.0.0.1  integrity.facebook.com
127.0.0.1  pan.facebook.com
127.0.0.1  tulip.facebook.com
127.0.0.1  nss.facebook.com
127.0.0.1  es.facebook.com
127.0.0.1  digits.facebook.com
127.0.0.1  tr.facebook.com
127.0.0.1  buffer.facebook.com
127.0.0.1  cms.facebook.com
127.0.0.1  demos.facebook.com
127.0.0.1  ca-es.facebook.com
127.0.0.1  management.facebook.com
127.0.0.1  src.facebook.com
127.0.0.1  api.facebook.com
127.0.0.1  ar-ar.facebook.com
127.0.0.1  sim.facebook.com
127.0.0.1  ja-jp.facebook.com
127.0.0.1  job.facebook.com
127.0.0.1  iso.facebook.com
127.0.0.1  blog.facebook.com
127.0.0.1  et-ee.facebook.com
127.0.0.1  just.facebook.com
127.0.0.1  ja-ks.facebook.com
127.0.0.1  lt-lt.facebook.com
127.0.0.1  govtrequests.facebook.com
127.0.0.1  hp.facebook.com
127.0.0.1  fa-ir.facebook.com
127.0.0.1  wave.facebook.com
127.0.0.1  conectadosbancogalicia.facebook.com
127.0.0.1  ru-ru.facebook.com
127.0.0.1  rand.facebook.com
127.0.0.1  workplace.facebook.com
127.0.0.1  pt-br.facebook.com
127.0.0.1  touch.facebook.com
127.0.0.1  health.facebook.com
127.0.0.1  www.prod.facebook.com
127.0.0.1  express.facebook.com
127.0.0.1  code.facebook.com
127.0.0.1  de-de.facebook.com
127.0.0.1  pl-pl.facebook.com
127.0.0.1  discovery.facebook.com
127.0.0.1  onevedanta.facebook.com
127.0.0.1  dav.facebook.com
127.0.0.1  zh-cn.facebook.com
127.0.0.1  sos.facebook.com
127.0.0.1  energy.facebook.com
127.0.0.1  cpanel.facebook.com
127.0.0.1  hr-hr.facebook.com
127.0.0.1  complex.facebook.com
127.0.0.1  development.facebook.com
127.0.0.1  nl-be.facebook.com
127.0.0.1  tr-tr.facebook.com
127.0.0.1  register.facebook.com
127.0.0.1  tools.facebook.com
127.0.0.1  iphone.facebook.com
127.0.0.1  ro.facebook.com
127.0.0.1  gaming.facebook.com
127.0.0.1  fr-fr.prod.facebook.com
127.0.0.1  he-il.facebook.com
127.0.0.1  sr-rs.facebook.com
127.0.0.1  quote.facebook.com
127.0.0.1  tickets.facebook.com
127.0.0.1  asia.facebook.com
127.0.0.1  stack.facebook.com
127.0.0.1  echo.facebook.com
127.0.0.1  redhat.facebook.com
127.0.0.1  apple.facebook.com
127.0.0.1  dns.facebook.com
127.0.0.1  business.facebook.com
127.0.0.1  new.facebook.com
127.0.0.1  staff.facebook.com
127.0.0.1  bc.facebook.com
127.0.0.1  student.facebook.com
127.0.0.1  es-es.facebook.com
127.0.0.1  sk-sk.facebook.com
127.0.0.1  error.facebook.com
127.0.0.1  pro.facebook.com
127.0.0.1  my.facebook.com
127.0.0.1  social.facebook.com
127.0.0.1  af-za.facebook.com
127.0.0.1  vector.facebook.com
127.0.0.1  ssl.facebook.com
127.0.0.1  cisco.facebook.com
127.0.0.1  sv-se.facebook.com
127.0.0.1  fr.facebook.com
127.0.0.1  grid.facebook.com
127.0.0.1  mbasic.facebook.com
127.0.0.1  email.facebook.com
127.0.0.1  africa.facebook.com
127.0.0.1  it.facebook.com
127.0.0.1  europe.facebook.com
127.0.0.1  trends.facebook.com
127.0.0.1  wwww.facebook.com
127.0.0.1  tm.facebook.com
127.0.0.1  en-gb.facebook.com
127.0.0.1  accounts.facebook.com
127.0.0.1  source.facebook.com
127.0.0.1  portal.facebook.com
127.0.0.1  nl-nl.facebook.com
127.0.0.1  login.facebook.com
127.0.0.1  ko-kr.facebook.com
127.0.0.1  zh-hk.facebook.com
127.0.0.1  th-th.facebook.com
127.0.0.1  osn.facebook.com
127.0.0.1  bridge.facebook.com
127.0.0.1  gps.facebook.com
127.0.0.1  is-is.facebook.com
127.0.0.1  sl-si.facebook.com
127.0.0.1  technic.facebook.com
127.0.0.1  fr-fr.facebook.com
127.0.0.1  keep-alive.facebook.com
127.0.0.1  c.facebook.com
127.0.0.1  ka-ge.facebook.com
127.0.0.1  event.facebook.com
127.0.0.1  bind.facebook.com
127.0.0.1  ap.facebook.com
127.0.0.1  jobs.facebook.com
127.0.0.1  ns.facebook.com
127.0.0.1  sandbox.facebook.com
127.0.0.1  terms.facebook.com
127.0.0.1  td.facebook.com
127.0.0.1  phone.facebook.com
127.0.0.1  bs-ba.facebook.com
127.0.0.1  az-az.facebook.com
127.0.0.1  sp.facebook.com
127.0.0.1  citrix.facebook.com
127.0.0.1  upload.facebook.com
127.0.0.1  webmail.facebook.com
127.0.0.1  hu-hu.facebook.com
127.0.0.1  resolver.facebook.com
127.0.0.1  beta.facebook.com
127.0.0.1  secure.facebook.com
127.0.0.1  connect.facebook.com
127.0.0.1  m.facebook.com
127.0.0.1  x.facebook.com
127.0.0.1  ads.facebook.com
127.0.0.1  vip.facebook.com
127.0.0.1  facebook.com
127.0.0.1  www.facebook.com
127.0.0.1  l.facebook.com
127.0.0.1  d.facebook.com
127.0.0.1  z.facebook.com
127.0.0.1  free.facebook.com
127.0.0.1  n.facebook.com
127.0.0.1  mobile.facebook.com
127.0.0.1  p.facebook.com
127.0.0.1  extern.facebook.com
127.0.0.1  intern.facebook.com
127.0.0.1  developers.facebook.com
127.0.0.1  community.facebook.com
127.0.0.1  driver.facebook.com
127.0.0.1  es-la.facebook.com
127.0.0.1  canvas.facebook.com
127.0.0.1  it-it.facebook.com
127.0.0.1  blue.facebook.com
127.0.0.1  w.facebook.com
127.0.0.1  radius.facebook.com
127.0.0.1  zh-tw.facebook.com
127.0.0.1  pata.facebook.com
127.0.0.1  da-dk.facebook.com
127.0.0.1  ida.facebook.com
127.0.0.1  transport.facebook.com
127.0.0.1  cs-cz.facebook.com
127.0.0.1  afa.facebook.com
127.0.0.1  ww.facebook.com
127.0.0.1  bg-bg.facebook.com
127.0.0.1  maxim.facebook.com
127.0.0.1  intro.facebook.com
127.0.0.1  vi-vn.facebook.com
127.0.0.1  ro-ro.facebook.com
127.0.0.1  apps.facebook.com
127.0.0.1  results.facebook.com
127.0.0.1  msg.facebook.com
127.0.0.1  update.facebook.com
127.0.0.1  fr-ca.facebook.com
127.0.0.1  pt-pt.facebook.com
127.0.0.1  mysql.facebook.com
127.0.0.1  fusion.facebook.com
127.0.0.1  boost.facebook.com
127.0.0.1  e127.0.0.1l-gr.facebook.com
127.0.0.1  axis.facebook.com
127.0.0.1  border.facebook.com
127.0.0.1  sap.facebook.com
127.0.0.1  fi-fi.facebook.com
127.0.0.1  id-id.facebook.com
127.0.0.1  vlan.facebook.com
127.0.0.1  ole.facebook.com
127.0.0.1  cvs.facebook.com
127.0.0.1  headlines.facebook.com
127.0.0.1  switch.facebook.com
127.0.0.1  ipc.facebook.com
127.0.0.1  target.facebook.com
127.0.0.1  doc.facebook.com
127.0.0.1  ta-in.facebook.com
127.0.0.1  asus.facebook.com
127.0.0.1  static.facebook.com
127.0.0.1  local.facebook.com
127.0.0.1  t.facebook.com
127.0.0.1  ibm.facebook.com
127.0.0.1  shop.facebook.com
127.0.0.1  ms-my.facebook.com
127.0.0.1  virtual.facebook.com
127.0.0.1  cgi.facebook.com
127.0.0.1  premier.facebook.com
127.0.0.1  vmware.facebook.com
127.0.0.1  nb-no.facebook.com
127.0.0.1  nn-no.facebook.com
127.0.0.1  about.facebook.com
127.0.0.1  light.facebook.com
127.0.0.1  o.facebook.com
127.0.0.1  0.facebook.com
127.0.0.1  www2.facebook.com
127.0.0.1  web.facebook.com
127.0.0.1  h.facebook.com
127.0.0.1  sms.facebook.com
127.0.0.1  ext.facebook.com
127.0.0.1  sv-se.facebook.com
```

## Privacy improvements in firefox `about:config`
* More settings: https://gist.github.com/0XDE57/fbd302cef7693e62c769

setting | set to | what it does
--- | --- | ---
`media.peerconnection.enabled` | false | disable Web Real-Time Communication
`geo.enabled` | false | false  | disable geolocation tracking
`media.navigator.enabled` | false | disable microphone and camera status tracking
`privacy.resistFingerprinting` | true | resists fingerprinting; __setting this to true will break google captchas__
`network.cookie.cookieBehavior` | 1 | block third party cookies
`network.dns.disablePrefetch` | true | disable DNS prefetching
`network.prefetch-next` | false | don't prefetch the next page
`webgl.disabled` | true | disable WebGL
`privacy.firstparty.isolate` | true | prevents tracking across different domains
`browser.send_pings` | false | prevent pages from tracking clicks
`dom.battery.enabled` | false | prevent websites from knowing your battery status
`dom.event.clipboardevents.enabled` | false | prevent websites from knowing if you copy or paste
`network.http.referer.trimmingPolicy` | 1 | Send the URL without its query string in the Referer header
`network.http.referer.XOriginPolicy` | 1 | Send Referer to same eTLD sites
`dom.event.contextmenu.enabled` | false | disable hijacking of the context menu; __setting this to false will break certain e-mail services__
`media.mediasource.webm.enabled` | false | relates to disabling autoplay
`dom.webnotifications.enabled ` | false | disable notifications from websites
`privacy.trackingprotection.cryptomining.enabled` | true | prevent crypto currency mining

### Stupidity
setting | set to | what it does
--- | --- | ---
app.update.auto | false | I don't think it is a good idea to let firefox decide when it's time to update.

### Change user agent
The default user agent in firefox will be something like

```
Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0
```

this is clearly more information than is needed. Why does "Ubuntu" and "x86_64" need to be in the user agent string? Remove! Create a new key `general.useragent.override` and set it to, for example:

```
Mozilla/5.0 (X11; Linux; rv:56.0) Gecko/20100101 Firefox/56.0
```

Taking it further, I think there is no need to broadcast that Linux and Firefox are under the hood at all:

```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.14
```

I think it's better not to completely remove the user agent string and not to change it to something obscure. Doing the latter will break multiple sites and it will instead facilitate fingerprinting.

## A simple calculator
`mate-calc`

## Useful Linux keyboard commands

keyboard combination | what it does
--- | ---
`ctrl+alt+f1` | go to console
`ctrl+a` | jump to beginning of line
`ctrl+e` | jump to end of line
`ctrl+k` | delete everything in front of the cursor
`alt+f` | jump one word forward
`alt+b` | jump one word backward

## Uncomplicated Firewall
Human-usable frontend for `iptables`.

```
apt-get install ufw
ufw default deny incoming
ufw default allow outgoing
ufw enable
ufw status verbose
```

## `gdm3` instead of LightDM
LightDM is default display manager in Xubuntu, handling the login and locked screens, etc. However, LightDM caused me problems with blank screen when using an external monitor. The problem can be addressed with xrandr but a quicker solution is just to switch to gdm3.

```
sudo apt-get install gdm3 xscreensaver
sudo apt-get remove lightdm
```

If the `Switch user` menu option doesn't work, press `ctrl+alt+f1` to switch user.

## Disable bluetooth from autostarting
My system came with the blueman applet, which autostarts bluetooth everytime I resume from suspend, etc. Permanently disable this behavior:

```
gsettings set org.blueman.plugins.powermanager auto-power-on false
```

Bluetooth can be temporary killed with:
```
rfkill block bluetooth
```

## Control Spotify from keyboard
Pause play, next and previous song. Can be added to as keyboard shortcuts through Xfce4 Settings.

```
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next
dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous
```

## Control volume from keyboard
`Settings -> Keyboard -> Application Shortcuts -> Add`

```bash
# Volume up by 10%
amixer set Master "10%+"

# Volume down by 10%
amixer set Master "10%-"
```

## Replacing proprietary and non-free software
Software to replace | Open source/free alternative
--- | ---
Microsoft Word | [LyX](https://www.lyx.org/)
Microsoft Powerpoint/Excel | [Libreoffice](https://www.libreoffice.org/)
Endnotes/Mendeley | [Zotero](https://www.zotero.org/)
Acrobat Reader | [Okular](https://okular.kde.org/)
any flowchart app | [Graphviz](https://www.graphviz.org/)
Sublime Text | [geany](https://www.geany.org/), [vim](https://www.vim.org/)
Photoshop, etc. | [GIMP](https://www.gimp.org)

## Other things useful
installation command | program name | what it is for
--- | --- | ---
`sudo apt install librsvg2-bin` | `rsvg-convert` | svg to pdf conversion
`sudo apt install xkeycaps` | `xkeycaps` | check keyboard layout
`sudo apt install r-base` | `R` | [R](https://www.r-project.org)
`sudo apt install feh` | `feh` | clutterless image viewer
`sudo apt install iptraf` | `iptraf-ng` | monitoring network traffic
`sudo apt install gpick` | `gpick` | a color picker
`sudo apt install tree` | `tree` | [Tree](http://mama.indstate.edu/users/ice/tree/), print structure of a directory tree
`sudo apt install pylint3` | `pylint` | linting python 3

## Check encoding of text file
`encguess`

## Monitor CPU speed
CPU speed:
```bash
lscpu | grep "^CPU"
```

Checking for example toggling when using the battery:
```
watch 'grep "cpu MHz" /proc/cpuinfo'
```

## tmux
Get the source of the most recent version from https://github.com/tmux/tmux/wiki

```
# needed to copile the above
sudo apt-get install libevent-dev
```

```
./configure
make
make install
```

# if `.tmux.conf` is changed, all running instances of tmux must be closed before this
# will take effect
```
$ cat ~/.tmux.conf
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

set -g status-bg blue

```

## Cheat sheet
Command | ?
--- | ---
`sudo apt-get purge <package>` | Remove package and conf files.

## zsh
I prefer zsh over bash.

```
sudo apt-get install zsh

chsh --shell /bin/zsh <username>

# logout and login
```

Install [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) to spice it up a bit.

```bash
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

### partial ~/.zshrc
```bash
# must be _before_ source oh-my-zsh
DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

# %n = username
# %m = machine/hostname
PROMPT="%{$fg[blue]%}%n${fg_white}[${fg_blue}%~${fg_white}]> "

autoload -U compinit
setopt autocd
setopt auto_resume

# useful aliases
# --------------
# image viewer
alias feh='feh --scale-down'

alias t='top -u <username>'

# gives free disk space
alias led="df -h | grep /dev/nvme0n1p1 | awk '{print \$4\" free disk space\"}'"

# what is my public IP?
alias pubip='wget -qO- https://ipecho.net/plain ; echo'

# nap time
alias sus="systemctl suspend"
alias ls="ls -N --color"

# for tmux
alias tml='tmux list-sessions'
alias tma='tmux attach-session'

alias cp="cp -vi"
alias mv="mv -vi"

alias xpdf="xpdf -rv -papercolor '#333333'"

alias ll='ls -H -N -slht -G --time-style="+%d %b %Y %H:%M"'
alias lll='ls -N -slhtG --color --time-style="+%d %b %Y %H:%M" | less -R'

alias grep="grep --color"

alias cal="ncal -bM"

# remove 'l' as an alias
unalias l

# change the color of directories from blue to violet
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS

# disable capslock
alias disable_capslock="/usr/bin/setxkbmap -option 'ctrl:nocaps'"
```

## Controlling brightness from command line
Yes, there are keys on the keyboard, but the increments are big. What if I just want to change 1%?

```bash
sudo apt-get install xbacklight

# increase 1%
xbacklight -inc 1

# decrease 1%
xbacklight -dec 1
```

## Disable trackpad
I sometimes want to disable the trackpad and only use the trackpoint.

```bash
xinput set-prop `xinput | grep Synaptics | sed 's/.*id=\(.*\)\t.*/\1/'` "Device Enabled" 0
```

## Trackpad stops working after waking up from sleep
```bash
sudo modprobe -r psmouse
sudo modprobe psmouse
```

## Modify mouse pointer image
I wanted to change the color of the xterm mouse cursor to make it more visible. Assuming the default mouse theme in `Xfce4` was not changed (DMZ White), the cursor image is in the file `/usr/share/icons/DMZ-White/cursors`. The file is an X11 cursor file:

```bash
$ file xterm
xterm: X11 cursor
```

and it can be opened in GIMP. The file consists of multiple layers. I modified each layer then exported it as an "X11 Mouse Cursor" file. Restart `Xfce4`. More details [here](http://shallowsky.com/linux/x-cursor-themes.html).

## Disable blinking for broken symlinks
I have symlinks to external drives, and I don't want them to be blinking when drives are not mounted. `$LS_COLORS` needs to be changed (I load mine from `~/.zshrc`). Edit the environmental variable `$LS_COLORS` and change `or=` (symbolic link pointing to a non-existent file, orphan) and `mi=` (non-existent file pointed to by a symbolic link) by removing the value `05;`. More details [here](http://linux-sxs.org/housekeeping/lscolors.html).

## Add syntax highlighting to `less`
Very useful to see syntax highlighted code when browsing with `less`.

```bash
sudo apt-get install source-highlight
```

Add to `~/.zshrc`:

```
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

# The following adds syntax highlighting to man pages
# Ref: https://goo.gl/ZSbwZI
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[37;44m'       # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline
```

# vim (Vi IMproved)
`vim` is a helpful friend.

## ~/.vimrc
```
set smartcase

set nopaste

highlight Comment ctermbg=Grey ctermfg=White
highlight Constant ctermbg=Yellow

syntax enable
hi Constant cterm=none
hi Special cterm=none
hi Identifier cterm=none

set numberwidth=5
set columns=85
set nu
set linebreak

set number

syntax on

ca W w
# good for white background
colorscheme morning
# Alternatives: blue.vim darkblue.vim default.vim delek.vim desert.vim elflord.vim evening.vim koehler.vim morning.vim murphy.vim pablo.vim peachpuff.vim ron.vim shine.vim slate.vim torte.vim zellner.vim
```

## keyboard
A reminder of useful shortcuts. More [here](http://www.sromero.org/wiki/linux/aplicaciones/vim_shortcuts).

keyboard | what it does
--- | ---
`daw` | deletes the word currently under the cursor (dots are not included)
`dt<char>` | Delete from cursor to `<char>`.

## Password-less ssh login
```bash
# generate keys (press enter two times when it asks for password)
ssh-keygen -t rsa
```
Then copy the public key (file ending with .pub) to `~/.ssh/authorized_keys` on the remote server.

Login through

`ssh -i ~/.ssh/private.key remote@ip`

## Set time zone
```bash
timedatectl list-timezones

sudo timedatectl set-timezone Asia/Manila
sudo timedatectl set-timezone Europe/Stockholm
```

## GoPro
```
sudo apt-get install exfat-utils exfat-fuse
cd /run/user/1000/gvfs/

# 2000000 bytes/second
ffmpeg -i input.mp4 -b 2000000 output.mp4
```

## Running an e-mail server
Running your own e-mail server is perhaps something we all should do instead of letting gmail read every one of our e-mails an building a profile of who we are. Running an e-mail server is actually a lot less complicated than it sounds. Here are the steps I took to setup postfix and anti-spam filters on a server I'm maintaining:

1. Make sure your domainname is in `/etc/mailname`

2. Install postfix
```bash
sudo apt-get install postfix
sudo service postfix start
```

3. Edit `/etc/postfix/main.cf` and make sure `smtpd_tls_cert_file` and `smtpd_tls_key_file` point to the files with your https certificates. I use LetsEncrypt, so for me it is `/etc/letsencrypt/live/foobar.com/fullchain.pem` and `/etc/letsencrypt/live/foobar.com/privkey.pem`, respectively. `myhostname` should be set to your domainame, `foobar.com`. `myorigin` should point to `/etc/mailname`. `mydestination` for me is `$myhostname, foobar.com, localhost.com, , localhost`.

Also make sure:

```
smtpd_use_tls=yes
smtpd_tls_auth_only=yes
smtp_tls_security_level=may
```

4. Add an Sender Policy Framework (SPF) record to your DNS config (this step is usually done in a config panel in the hosting company for your domainname):

```
TXT		v=spf1 ip4:<server IP goes here> ~all
```

5. DKIM is another layer of e-mail security, which we need to have:
```
sudo apt-get install opendkim opendkim-tools
```

6. My `/etc/opendkim.conf` looks like this:

```
AutoRestart             Yes
AutoRestartRate         10/1h
UMask                   002
SyslogSuccess           Yes
LogWhy                  Yes

Canonicalization        relaxed/simple

ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts
InternalHosts           refile:/etc/opendkim/TrustedHosts
KeyTable                refile:/etc/opendkim/KeyTable
SigningTable            refile:/etc/opendkim/SigningTable

Mode                    sv
PidFile                 /var/run/opendkim/opendkim.pid
SignatureAlgorithm      rsa-sha256

UserID                  opendkim:opendkim

Socket                  inet:12301@localhost
```

7. Edit `SOCKET` using `sudo vim /etc/default/opendkim`, it can be different but mine is:

`SOCKET="local:/var/spool/postfix/var/run/opendkim/opendkim.sock"`

8. Setup postfix:

```sudo vim /etc/postfix/main.cf```

Add the following lines:
```
content_filter = smtp-amavis:[127.0.0.1]:10024

milter_protocol = 2
milter_default_action = accept

smtpd_milters = inet:127.0.0.1:12301
non_smtpd_milters = inet:127.0.0.1:12301
```

9. Run `sudo mkdir /etc/opendkim` and `sudo mkdir /etc/opendkim/keys`

10. `sudo vim /etc/opendkim/TrustedHosts` add:

```
127.0.0.1
localhost
192.168.0.1/24
```

11. `sudo vim /etc/opendkim/KeyTable` add
```
mail._domainkey.foobar.com foobar.com:mail:/etc/opendkim/keys/foobar.com/mail.private
```

12. `sudo vim /etc/opendkim/SigningTable` add:
```
*@foobar.com mail._domainkey.foobar.com
```

13. `cd /etc/opendkim/keys`

```
sudo mkdir foobar.com
cd foobar.com

sudo opendkim-genkey -s mail -d foobar.com

sudo chown opendkim:opendkim mail.private

sudo cat mail.txt`
```

14. Add TXT record to the subdomain mail._domainkey in the DNS editor at the hosting provider:

```
v=DKIM1; h=sha256; k=rsa; p=<LONG KEY FROM ABOVE HERE>
```

15. Restart postfix
```
sudo service postfix restart

# bug in the opendkim startup script, it doesn't read the port properly, solution is to start it manually
sudo service opendkim stop
sudo su
opendkim
exit

netstat -l # check that it is running on port 12301
```

16. confirm it is there (you should see your key):

```
dig +short mail._domainkey.foobar.com TXT
```

17. Install amavis (for anti-spam); there is also spamassassin, but amavis is better.
```bash
sudo apt-get install amavisd-new spamassassin clamav-daemon
sudo apt-get install libnet-dns-perl libmail-spf-perl pyzor razor
sudo apt-get install arj bzip2 cabextract cpio file gzip lha nomarch pax rar unrar unzip unzoo zip zoo

sudo adduser clamav amavis
sudo adduser amavis clamav
sudo su - amavis -s /bin/bash
razor-admin -create
razor-admin -register
pyzor discover

sudo service amavis start
sudo service spamassassin stop
```

18. Activate spam and antivirus detection in Amavis by uncommenting lines in `/etc/amavis/conf.d/15-content_filter_mode`.

19. After configuration Amavis needs to be restarted: `sudo /etc/init.d/amavis restart`

20. For postfix integration, you need to add the content_filter configuration variable to the Postfix configuration file `/etc/postfix/main.cf`. This instructs postfix to pass messages to amavis at a given IP address and port:

```
content_filter = smtp-amavis:[127.0.0.1]:10024
```

21. Next edit `/etc/postfix/master.cf` and add the following to the end of the file:

```
smtp-amavis     unix    -       -       -       -       2       smtp
        -o smtp_data_done_timeout=1200
        -o smtp_send_xforward_command=yes
        -o disable_dns_lookups=yes
        -o max_use=20

127.0.0.1:10025 inet    n       -       -       -       -       smtpd
        -o content_filter=
        -o local_recipient_maps=
        -o relay_recipient_maps=
        -o smtpd_restriction_classes=
        -o smtpd_delay_reject=no
        -o smtpd_client_restrictions=permit_mynetworks,reject
        -o smtpd_helo_restrictions=
        -o smtpd_sender_restrictions=
        -o smtpd_recipient_restrictions=permit_mynetworks,reject
        -o smtpd_data_restrictions=reject_unauth_pipelining
        -o smtpd_end_of_data_restrictions=
        -o mynetworks=127.0.0.0/8
        -o smtpd_error_sleep_time=0
        -o smtpd_soft_error_limit=1001
        -o smtpd_hard_error_limit=1000
        -o smtpd_client_connection_count_limit=0
        -o smtpd_client_connection_rate_limit=0
        -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks

Also add the following two lines immediately below the "pickup" transport service:

-o content_filter=
-o receive_override_options=no_header_body_checks
```

```
sudo service postfix restart
```

```
If the filtering is not happening, adding the following to /etc/amavis/conf.d/50-user may help:

@local_domains_acl = ( ".$mydomain" );

sudo /etc/init.d/postfix restart
sudo /etc/init.d/clamav-daemon restart
sudo /etc/init.d/amavis restart
```

22. decrease the threshold for spam

```
sudo vim /etc/amavis/conf.d/20-debian_defaults
# change to 5
$sa_kill_level_deflt = 5; # triggers spam evasive actions
sudo service amavis restart
```

23. Add reverse DNS for your server. This is done with your DNS provider. After setting a reverse DNS a `nslookup <your ip>` should result in your domain name. An invalid reverse DNS is often a sign of bad servers.

24. Done! Enjoy your mail server. Now big brother cannot 'noop anymore. Final note: it will take some time to build up a "reputation" in order to avoid being classified as spam by other e-mail servers. Patience is needed.

### ignore certain domains
How to ignore, for example, all incoming emails from the domain @grab.com
```bash
sudo vim /etc/postfix/header_checks
```

Add the following line:
```
/^From: .*@grab.com/       REJECT
```

```bash
sudo vim /etc/postfix/main.cf
```

Add the following line:
```
header_checks = regexp:/etc/postfix/header_checks
```

Restart postfix
```bash
sudo service postfix restart
```

# Shared memory segments
Useful after working with the [STAR aligner](https://github.com/alexdobin/STAR) to delete memory segments.
```bash
# list
ipcs
# remove specific
ipcrm -m <shmid>
```

# Restore terminal window after a stalled SSH
See here: https://apple.stackexchange.com/questions/35524/what-can-i-do-when-my-ssh-session-is-stuck

Typed `suspend` while having active SSH sessions in a terminal just to get back and having to close the terminal window? No more.

```
~. to terminate the connection (alt gr+tilde button+space+dot+enter)
``` 

# Remove `whoopsie`
I found this one running and I had no idea what it is and why it is there. It turns out to be an ubuntu error reporting daemon. I decided to remove it.
```
sudo apt-get purge whoopsie
```

# Xfce4 version 4.14.0 - high CPU usage issue
* This does not seem to fix the problem entirely
* https://bugzilla.xfce.org/show_bug.cgi?id=15963
```
xfwm4 -V
	This is xfwm4 version 4.14.0 (revision ed87ef663) for Xfce 4.14
	Released under the terms of the GNU General Public License.
	Compiled against GTK+-3.22.30, using GTK+-3.22.30.

	Build configuration and supported features:
	- Startup notification support:                 Yes
	- XSync support:                                Yes
	- Render support:                               Yes
	- Xrandr support:                               Yes
	- Xpresent support:                             Yes
	- Embedded compositor:                          Yes
	- Epoxy support:                                Yes
	- KDE systray proxy (deprecated):               No
```

Run and restart xfce4:
```
xfconf-query -c xfwm4 -p /general/vblank_mode -s xpresent
```

# The MATE desktop environment
* A maintained fork of GNOME2

```
sudo apt-get install mate-desktop-environment
```

### Window focusing problem
* I still prefer `xfce4-terminal`, and I usually add a shortcut so that a terminal window opens up with when pressing F3. A bug causes the terminal window to end up _below_ current windows. A small workaround using `wmctrl`:

First install wmctrl:
```
sudo apt install wmctrl
```

Create a small helper script and link F3 to it (don't forget to chmod +x it):
```
xfce4-terminal
wmctrl -i -a `wmctrl -l | tail -n1 | cut -d ' ' -f1`
```

### Disable `compton` fading, shadows, etc
* More compton tweaks: https://wiki.archlinux.org/index.php/Compton

In `/etc/xdg/xdg-xubuntu/compton.conf` set
```
fading = false;
shadow = false;
```

# Enter Ubuntu's rescue mode
* Hold shift just after the Vendor "Lenovo" screen
* Enable networking from CLI with `service network-manager start`

# Reload /etc/fstab
```
sudo mount -a
```

# icewm
A simple, lightweight, no BS, window manager.
```
sudo apt-get install icewm
sudo apt-get install xkbset
```
Add to `~/.xinitrc`:
```
exec icewmbg -a=1 &
exec xscreensaver -nosplash &
exec dbus-launch icewm-session
exec xset r rate 200 40
# list settings
#xkbset q
# disable slow keys
xkbset -sl
# disable accessibility
xkbset -a
# repeat rate
xkbset r rate 200
xkbset bo 10
xkbset -bo
```

Start through `startx`.

# Turn mitigations off
* See here for details and warnings: https://linuxreviews.org/HOWTO_make_Linux_run_blazing_fast_(again)_on_Intel_CPUs
* In `/etc/default/grub` add `mitigations=off` to `GRUB_CMDLINE_LINUX_DEFAULT` and run `sudo update-grub`

# xscreensaver
The config resides in `~/.xscreensaver`. The only thing I changed was to set `lock:` to `False`, because having xscreensaver lock caused me a problem when disconnecting external screen/sleep suspend.

# touchpad sensitivity
* Details: https://help.ubuntu.com/community/SynapticsTouchpad

```
# figure out the id
$ xinput --list
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ Logitech Wireless Mouse                 	id=9	[slave  pointer  (2)]
⎜   ↳ Synaptics TM3288-011                    	id=10	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Power Button                            	id=6	[slave  keyboard (3)]
    ↳ Video Bus                               	id=7	[slave  keyboard (3)]
    ↳ Sleep Button                            	id=8	[slave  keyboard (3)]
    ↳ Integrated Camera: Integrated C         	id=12	[slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard            	id=13	[slave  keyboard (3)]
    ↳ ThinkPad Extra Buttons                  	id=14	[slave  keyboard (3)]
    ↳ Logitech Wireless Mouse                 	id=16	[slave  keyboard (3)]


xinput --set-prop 10 "Synaptics Finger" 50 40 107

# disable it completely
xinput --disable 10
```

# Xorg
### Log file location
```
/home/USERNAME/.local/share/xorg/
```

# git
### password-less ssh interactions
1. Option 1: remove password from the ssh keys
2. Option 2:

```bash
ssh-agent
export SSH_AUTH_SOCK=/tmp/ssh-XXXXXXX/agent.XXXX
ssh-add ~/.ssh/id_rsa_XXXXX
```

# No GUI for GPG
* https://superuser.com/questions/520980/how-to-force-gpg-to-use-console-mode-pinentry-to-prompt-for-passwords
```
sudo apt-get install pinentry-tty
```

In `~/.gnupg/gpg-agent.conf` add:

```
pinentry-program /usr/bin/pinentry-tty
```

Reload

```
gpg-connect-agent reloadagent /bye
```

# Prevent going to sleep upon lid closure when on battery
`sudo vim /etc/systemd/logind.conf` and set `HandleLidSwitch=ignore` then `systemctl restart systemd-logind.service`.

# urxvt
```
$ cat ~/.Xdefaults
URxvt*background: black
URxvt*foreground: white

# default font is called "6x13"
URxvt.font: 7x14
```
# Figure out which process launched a certain X window
```
xwininfo
xprop -id <ID>
```

# i3
### run xrandr at launch and disable touchpad
Put in `/etc/X11/Xsession.d/90xrandr`:

```
xrandr --output eDP1 --mode 2048x1152
xinput --disable $(xinput --list | grep "Synaptics TM3288-011" | sed 's/.*id=\([0-9]*\).*/\1/')
```

# quotable-printable
```
apt install tokyocabinet-bin

# decode
tcucodec quote -d myInput.qp
```

# execsnoop
A small tool written in Bash useful for detecting small shortlived
processes.

* https://github.com/brendangregg/perf-tools/blob/master/execsnoop

# create a zombie process
- https://stackoverflow.com/questions/25172425/create-zombie-process

create a `zombie.c` and run `gcc zombie.c -o zombie`:
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void)
{
    pid_t pid;
    int status;

    if ((pid = fork()) < 0) {
        perror("fork");
        exit(1);
    }

    /* Child */
    if (pid == 0)
        exit(0);

    /* Parent
     * Gives you time to observe the zombie using ps(1) ... */
    sleep(100);

    /* ... and after that, parent wait(2)s its child's
     * exit status, and prints a relevant message. */
    pid = wait(&status);
    if (WIFEXITED(status))
        fprintf(stderr, "\n\t[%d]\tProcess %d exited with status %d.\n",
                (int) getpid(), pid, WEXITSTATUS(status));

    return 0;
}
```

Create the zombie
```bash
{ nohup ./zombie & } &
```

# Making emacs work nicely with zsh
Add the following line to `~/.zshenv`:

```bash
export EMACS="*term*"
```

# xterm
put these in `~/.Xdefaults` _and_ `~/.Xresources`.

```
xterm*background: #ffffff
xterm*foreground: #000000
xterm.*backarrowKey: false 

xterm*metaSendsEscape:  true
xterm*eightBitInput: false

xterm*VT100.Translations: #override \
                 Ctrl Shift <Key>V:    insert-selection(CLIPBOARD) \n\
                 Ctrl Shift <Key>C:    copy-selection(CLIPBOARD)

```

then

```
xrdb ~/.Xresources
pkill xterm
xterm
```
