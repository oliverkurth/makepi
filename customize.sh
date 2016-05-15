#!/bin/sh

http_proxy="" wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
http_proxy="" wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
apt-get update
apt-get -y upgrade

apt-get install -y --force-yes sudo openssh-server ntp patch less rsync vim
apt-get install -y --force-yes iw wpasupplicant hostapd crda dnsmasq pi-bluetooth
apt-get install -y --force-yes firmware-brcm80211 firmware-realtek firmware-ralink
apt-get install -y --force-yes git
apt-get install -y --force-yes python python-flask python-httplib2 python-netifaces
apt-get install -y --force-yes nginx-common nginx-extras uwsgi uwsgi-plugin-python
 
adduser pi
usermod -a -G sudo,staff,kmem,plugdev pi

apt-get clean

systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable iptables

