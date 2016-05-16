#!/bin/sh

chrootdir=$1
pypiwifi_dir=~/pypiwifi/

if [ ! -d ${pypiwifi_dir} ] ; then
        echo "${pypiwifi_dir} does not exist - you need to clone https://github.com/oliverkurth/pypiwifi.git"
        exit 1
fi

cp -R ${pypiwifi_dir} ${chrootdir}/home/pi
chown -R 1000:1000 ${chrootdir}/home/pi/pypiwifi

