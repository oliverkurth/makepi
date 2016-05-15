#!/bin/bash

sdsize=3780

debianurl=http://archive.raspbian.org/raspbian
dist=jessie
arch=armhf

fwdir=~/firmware/
fwdir_nonfree=~/firmware-nonfree/
chrootdir=chroot-raspbian-${arch}
image_name=raspbian-jessie.img

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
	rm -rf ${chrootdir}
	if [ -f ${chrootdir}.tgz ] ; then
		echo "Unpacking root filesystem"
		tar zxf ${chrootdir}.tgz
	else
		echo "Creating root filesystem"
		qemu-debootstrap --arch ${arch} ${dist} ${chrootdir} ${debianurl} || exit 1
		tar zcf ${chrootdir}.tgz ${chrootdir}
	fi

	cp -R ${fwdir}/hardfp/opt/* ${chrootdir}/opt/

	mkdir -p ${chrootdir}/lib/modules/
	cp -R ${fwdir}/modules/* ${chrootdir}/lib/modules/
}

clean_rootfs() {
	echo "Cleaning up filesystem"
	rm -f ${chrootdir}/usr/bin/qemu-arm-static
	rm -rf ${chrootdir}/var/cache/apt
}

make_bootfs() {
	echo "Creating bootfs"
	mkdir -p ./bootfs
	cp -R ${fwdir}/boot/* bootfs/
}

make_fs() {
	if [ -f ${chrootdir}-customized.tgz ] ; then
		echo "Skipping creating flesystem because ${chrootdir}-customized.tgz exists"
	else
		make_rootfs
	fi
	make_bootfs
}

make_image() {
	echo "Creating raw image"

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
	if [ -f ${chrootdir}-customized.tgz ] ; then
		echo "Unpacking customized filesystem"
		rm -rf ${chrootdir}
		tar zxf ${chrootdir}-customized.tgz
	else
		echo "Customizing filesystem"

		cp -R overlay/* ${chrootdir}

		mount_all
		cp customize.sh ${chrootdir}/root
		chroot ${chrootdir} /root/customize.sh

		# kill everything executed with qemu-arm-static:
		pkill -f /usr/bin/qemu-arm-static
		sleep 3
		pkill -9 -f /usr/bin/qemu-arm-static
		sleep 3

		umount_all
		tar zcf ${chrootdir}-customized.tgz ${chrootdir}
	fi
}

copy_image() {
	echo "Copying files to image"
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

make_fs
customize
clean_rootfs
make_image
copy_image

