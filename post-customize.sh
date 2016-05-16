#!/bin/sh

chrootdir=$1
pypiwifi_dir=~/pypiwifi/

cp -R ${pypiwifi_dir} ${chrootdir}/home/pi
chown -R 1000:1000 ${chrootdir}/home/pi/pypiwifi

