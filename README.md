# Linux on the ThinkPad X1 Carbon 6th
## About this document
In this document I'm collecting some of the configuration tweaks I did to setup Linux on my ThinkPad X1 Carbon 6th - primarily so that I can repeat them quickly in case I need to reinstall; I'm including some general Linux configuration that is not specific for the Thinkpad. The good news is that most things work out of the box after installing [Xubuntu](https://xubuntu.org/) bionic, but there are some exceptions. (In fact more things seem to work out of the box with Xubuntu compared with regular Ubuntu on the TX1C6.) Another excellent document which also works well for Xubuntu on the TX1C6 is the [Arch Linux guide](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)).

- Oscar <p.oscar.franzen@gmail.com>

## Why run Linux on the ThinkPad
My goal, while not achieved yet, is to eventually replace all my usage of Apple software with free counterparts.

## The system
```bash
$ sudo dmidecode -s system-version
ThinkPad X1 Carbon 6th
```

### Non-fixable problems
* The screen has one dead pixel

## TODO
* Check BIOS setting for powersaving for Thunderbolt 3

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
fi
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

~~sudo vim /usr/lib/pm-utils/sleep.d/99ZZ_disable_capslock~~

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

## `xfce4-terminal`
### Changing shortcut keys for `xfce4-terminal`
I prefer to be able to open a new terminal tab with `ctrl+t` and close a tab with `ctrl+w`. Fortunately this is easy to fix:
1. Fire ```vim /home/rand/.config/xfce4/terminal/accels.scm```
2. Then add
```
(gtk_accel_path "<Actions>/terminal-window/close-tab" "<Primary>w")
(gtk_accel_path "<Actions>/terminal-window/new-tab" "<Primary>t")
(gtk_accel_path "<Actions>/terminal-window/search" "<Primary>f")
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

Put in crontab:

```bash
#!/bin/bash

if [ -e /dev/disk/by-uuid/UUID ]; then
  /path/to/rsync_tmbackup.sh --no-auto-expire /home/foobar /mount/point/of/backup .exclude_backup_patterns
else
  echo "backup drive not found"
fi
```

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

Lines to add
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

## A simple calculator
`mate-calc`

## Useful Linux keyboard commands

keyboard combination | what it does
--- | ---
`ctrl+alt+f1` | go to console

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

## Replacing proprietary software
Software to replace | Open source/free alternative
--- | ---
Microsoft Word | [LyX](https://www.lyx.org/)
Microsoft Powerpoint/Excel | [Libreoffice](https://www.libreoffice.org/)
Endnotes | [Zotero](https://www.zotero.org/)
Acrobat Reader | [Okular](https://okular.kde.org/)
any flowchart app | [Graphviz](https://www.graphviz.org/)
Sublime Text | [geany](https://www.geany.org/), [vim](https://www.vim.org/)

## Other things useful
installation command | program name | what it is for
--- | --- | ---
`sudo apt install librsvg2-bin` | `rsvg-convert` | svg to pdf conversion
`sudo apt install xkeycaps` | `xkeycaps` | check keyboard layout
`sudo apt install r-base` | `R` | [R](https://www.r-project.org)

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
```
sudo apt-get install tmux
```

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

```bash
# partial ~/.zshrc
PROMPT="
%{$fg[blue]%}%n${fg_white}[${fg_blue}%~${fg_white}]> "
autoload -U compinit
setopt autocd
setopt auto_resume
DISABLE_AUTO_UPDATE="true"
```

## Controlling brightness from command line
```
sudo apt-get install xbacklight

# increase 5%
xbacklight -inc 5

# decrease 5%
xbacklight -dec 5
```
