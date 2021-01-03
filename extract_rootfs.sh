#!/bin/sh

image_src=$1
rootfs_dest=$2
rootfs_line=$(fdisk -l "$image_src" | grep img2)
rootfs_start=$(echo $rootfs_line | awk '{ print $2 }')
rootfs_size=$(echo $rootfs_line | awk '{ print $4 }')
echo start=${rootfs_start}
echo size=${rootfs_size}

dd if=$image_src of=$rootfs_dest bs=512 skip=$rootfs_start count=$rootfs_size status=progress


