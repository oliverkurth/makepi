#!/bin/sh

wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
apt-get update
apt-get -y upgrade

apt-get install -y sudo openssh-server ntp patch less rsync
apt-get install -y iw wpasupplicant hostapd dnsmasq pi-bluetooth
apt-get install -y firmware-brcm80211
 
adduser pi
usermod -a -G sudo,staff,kmem,plugdev pi

apt-get clean

