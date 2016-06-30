#!/bin/bash
#wmf
echo "mount.sh starting"

#echo "mount.sh sleeping"
#sleep 1m
#echo "mount.sh waking"
#echo "mount.sh loggin"
#fdisk -l | grep mmcblk0 > /usr/local/mount.log
#df -h | grep mmcblk0 > /usr/local/mount.log

# if you mount to /data, expect strange behavior:
#1 purge /data will not work
#2 /data is actually persistent across apps
#echo "mount.sh unmounting /data"
#umount /data

echo "mount.sh mounting sc card to /media"
mount -t btrfs /dev/mmcblk0p1 /media

#echo "mount.sh loggin"
#fdisk -l | grep mmcblk0 > /usr/local/mount.log
#df -h | grep mmcblk0 > /usr/local/mount.log

echo "mount.sh ending"
