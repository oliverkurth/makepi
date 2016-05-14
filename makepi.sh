#!/bin/bash

sdsize=3780

debianurl=http://archive.raspbian.org/raspbian
dist=jessie
arch=armhf

fwdir=~/firmware/
fwdir_nonfree=~/firmware-nonfree/
chrootdir=chroot-raspbian-${arch}
image_name=rasbian-jessie.img

mount_all() {
	mount -t proc proc ${chrootdir}/proc
	mount -t sysfs sysfs ${chrootdir}/sys
	mount -o bind /dev ${chrootdir}/dev
}

umount_all() {
	umount --force ${chrootdir}/dev
	umount --force ${chrootdir}/sys
	umount --force ${chrootdir}/proc
}

make_rootfs() {
	if [ -f ${chrootdir}.tgz ] ; then
		tar zxf ${chrootdir}.tgz
	else
		qemu-debootstrap --arch ${arch} ${dist} ${chrootdir} ${debianurl}
		tar zcf ${chrootdir}.tgz ${chrootdir}
	fi

	cp -R ${fwdir}/hardfp/opt/* ${chrootdir}/opt/

	mkdir -p ${chrootdir}/lib/modules/
	cp -R ${fwdir}/modules/* ${chrootdir}/lib/modules/

	cp -R overlay/* ${chrootdir}
}

clean_rootfs() {
	rm -f ${chrootdir}/usr/bin/qemu-arm-static
	rm -rf ${chrootdir}/var/cache/apt
}

make_bootfs() {
	mkdir ./bootfs
	cp -R ${fwdir}/boot/* bootfs/
}

make_image() {

	dd if=/dev/zero of=${image_name} bs=1M count=3780
	device=$(losetup -f --show ${image_name})
	fdisk ${device} << EOF
n
p
1
 
+64M
t
c
n
p
2
 
 
w
EOF
	losetup -d ${device}
}

customize() {
	mount_all
	cp customize.sh ${chrootdir}/root
	chroot ${chrootdir} /root/customize.sh
	umount_all
}

copy_image() {
	dev=$(kpartx -va ${image_name} | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1)

	mkfs.vfat /dev/mapper/${dev}p1
	mkfs.ext4 /dev/mapper/${dev}p2

	mkdir -p /mnt/rootfs
	mount /dev/mapper/${dev}p2 /mnt/rootfs
	rsync -a ${chrootdir}/ /mnt/rootfs/
	cp -a ${fwdir}/hardfp/opt/vc /mnt/rootfs/opt/
	umount /mnt/rootfs

	mkdir -p /mnt/bootfs
	mount /dev/mapper/${dev}p1 /mnt/bootfs
	cp -R bootfs/* /mnt/bootfs

#	cp config.txt /mnt/bootfs/config.txt 
	cp cmdline.txt /mnt/bootfs/cmdline.txt 
 
	umount /mnt/bootfs

	kpartx -d ${image_name}
}

make_image
make_bootfs
make_rootfs
customize
clean_rootfs
copy_image

