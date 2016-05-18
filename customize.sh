#!/bin/sh

wget http://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -
apt-get update
apt-get -y upgrade

apt-get install -y --force-yes sudo openssh-server ntp patch less rsync vim parted
apt-get install -y --force-yes iw wpasupplicant hostapd crda dnsmasq pi-bluetooth
apt-get install -y --force-yes firmware-brcm80211 firmware-realtek firmware-ralink bluez-firmware
apt-get install -y --force-yes git
apt-get install -y --force-yes python python-flask python-httplib2 python-netifaces
apt-get install -y --force-yes nginx-common nginx-extras uwsgi uwsgi-plugin-python

# password is 'raspberry' 
useradd -m pi -s /bin/bash -p '$6$24rIum07$C07au5jT1GDCaT7QIO4QpYfMmciSTEyeuhfNonEvM8E7NowPa1d2Gt9kMpxSnGJL1G/VvEXY2w6IA9FS.ipjF1'
usermod -a -G sudo,staff,kmem,plugdev pi

apt-get clean

# bug fix for raspbian
chmod u+s /bin/ping

systemctl enable hostapd
systemctl enable dnsmasq
systemctl enable iptables

