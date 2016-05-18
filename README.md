# makepi

## Overview

This is a shell script that creates an sd card image for the Raspberry Pi. The image is based on raspbian/jessie,
making use of debootstrap and qemu.

The code is based on this tutorial (in German):
http://raspberry.tips/raspberrypi-tutorials/eigenes-raspbian-image-fuer-den-raspberry-pi-erstellen/ 
but no interaction is required. I also updated it to use jessie instead of wheezy, aded code
to customize the image further, and added a firstboot script to automatically resize the root partition
(based on Hypriot with minor changes).

The current code in the master branch will build an image a wireless router that should work out of
the box when installed in a Raspberry Pi3. It will start an access point and dhcp server and use
ethernet for internet access.

If you check out the pypiwifi branch it will add a web interface to control the access point. You will
need to clone https://github.com/oliverkurth/pypiwifi as well.

## Requirements

This has been tested in a Ubuntu 15.10 VM. It will most likely work on any recent Debian or Ubuntu system.
The following packages need to be installed:

* qemu-user-static
* kpartx

You also need to clone the repository https://github.com/raspberrypi/firmware.git.
The script expects this to be in your home directory.

## How to use

cd makepi
sudo ./makepi.sh

That's all.

When you rerun this often, I recommend to use a proxy for the packages that will be installed. I use apt-cacher-ng.

## Hacking

To make multiple iterations more efficient, the script makes backups after time (and bandwidth) consuming stages.

In the first stage, the script uses qemu-debootstrap to create a root file system. Since this rarely changes,
this is backed up as chroot-raspbian-armhf.tgz. In a subsequent run, this stage will be skipped if the backup exists,
and instead the tarball will just be unpacked.

In the second stage, the root file system is cutomized, using 3 scripts:
* pre-customize.sh
* customize.sh
* post-custimize.sh

The pre/post scripts are optional and run outside the chroot environment. This makes it possible to copy
files from other places. The script customize.sh runs in a chroot'ed environment. This makes it possible to execute
programs as if the system is already alive, and for example run apt-get. However, it's not possible to access files
from outside the root file system.

Before pre-customize.sh is run files will be copied from overlay. This is useful for preconfigured configuration files.

The customized filesystem will also be backed up as chroot-raspbian-armhf-customized.tgz. Remember that when you make
changes in the customization to delete that file before unning makepi.sh again.

Finally, a raw image will be created and formated, mounted and the file system copied over.
This can be copied to an sd card using dd.

