# Linux on the Thinkpad X1 Carbon 6th
## About this document
I'm here collecting some of the configuration tweaks I did to setup Linux on my Thinkpad X1 Carbon 6th. Most things work out of the box after installing [Xubuntu](https://xubuntu.org/), but there are some exceptions. Another excellent document which also works well for Xubuntu on the TXC6 is the [Arch Linux guide](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)).

## The system
```bash
$ sudo dmidecode -s system-version
ThinkPad X1 Carbon 6th
```

## Crucial BIOS update
The BIOS of the machine needs to be flashed, because unfortunately, the manufacturer has removed support for suspend to RAM support (aka S3 deep sleep). Instead the TX1C6 supports a new macish sleep mode (where the system can be woken up anytime by software), but the Linux kernel does not to my understanding support it yet. Lenovo later issued a BIOS update for the TX1C6, allowing the use of S3.
