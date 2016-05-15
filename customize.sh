#!/bin/sh

wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
apt-get update
apt-get -y upgrade

apt-get install -y sudo openssh-server ntp patch less rsync vim
apt-get install -y iw wpasupplicant hostapd dnsmasq pi-bluetooth
apt-get install -y firmware-brcm80211 firmware-realtek firmware-ralink
apt-get install -y git
apt-get install -y python python-flask python-httplib2 python-iwlib python-netifaces
apt-get install -y nginx-common nginx-extras uwsgi uwsgi-plugin-python
 
adduser pi
usermod -a -G sudo,staff,kmem,plugdev pi

apt-get clean

systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable iptables

