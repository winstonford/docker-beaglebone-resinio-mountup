# Mount Up

A bone simple resin.io app that mounts a micro sd card in a beaglebone black running docker.

To work on bare metal,

>you can't be any geek off the street, gotta be handy with the steel

Resinators, mount up!

## What

This triple simple app will mount an micro sd card that's been inserted into a beaglebone black running on resin.io.  

On resin.io, in order to get terminal access and shell into your linux device, you need to first have an app on the device.  So you can use this app as a simple starting point and then merge the components into another app.   


## Why

On a mac or similar, when you plugin a memory card or a usb drive, the volume shows up automatically.

But on simpler SOC devices like a beaglebone black, this process of mounting may not be automatic.

The resino base application requires a bit under 2gb of space.  But on a beaglebone rev B, there is only 2gb of onboard memory (on the rev C there is 4gb).  So on boot and before adding an app, the disk may already be over 70% full.

With this app, you can easily expand the storage space on a beaglebone black with a micro sd card.  They come in sizes of 8,16,32,64,128 gb.


 
## How 

### Get a card 

Get a micro sd card. [Sandisk](https://www.amazon.com/dp/B010Q57T02/) works well.  Erase and format the card in FAT format.   On a mac, Disk Utility will do this. 

### Find the volume

Insert the sc card into the beaglebone, drop into a terminal in the resin dashboard, and look for the volume:

```
root@beaglebone-add648:/# fdisk -l | grep mmcblk0  
```

You should see something like this:

```                                                                               
Disk /dev/mmcblk0: 14.7 GiB, 15719727104 bytes, 30702592 sectors                                                                  
/dev/mmcblk0p1       8192 30702591 30694400 14.7G  b W95 FAT32
```

Don't see the volume? Scroll on down to **Trouble Shooting** If you see it, move right along.



### Format

Resin formats the /data volume in btrfs, so do the same.  Use the beaglebone to do the formatting by inserting the card, dropping into a Resin terminal, and run:

```
apt-get update && apt-get install btrfs-tools
```

then format the card:

```
mkfs.btrfs /dev/mmcblk0p1
```

You may get this result:

```
/dev/mmcblk0p1 appears to contain an existing filesystem (exfat).
Error: Use the -f option to force overwrite.
```

so force it:

```
mkfs.btrfs -f /dev/mmcblk0p1
```

In the output you may see:

```
Detected a SSD, turning off metadata duplication.
```

This one feature of btrfs, that it distinguishes solid state memory from a spinning disk drive.

### Check

Check to make sure the volume is formatted to btrfs:

```
blkid /dev/mmcblk0p1
```


Look for TYPE="btrfs" at the end of the output:

```
/dev/mmcblk0p1: UUID="af4061b8-9b97-4d55-a0dc-7510a82cde99" UUID_SUB="7b8a9341-fc48-4a48-9116-23638f2086c3" TYPE="btrfs"
```

At this point you are pretty much done.  Going forward, the sd card stays in the beaglebone and the data on it is persistent.  

### Reboot

Once sc card is formatted, use the Resin dashboard or cli to reboot.  Basic log messages will show up in the dashboard device log:

```
28.06.16 12:57:20 [-0400] Systemd init system enabled.
28.06.16 12:57:27 [-0400] mount.sh starting
28.06.16 12:57:28 [-0400] mount.sh unmounting /media
28.06.16 12:57:28 [-0400] mount.sh mounting sc card to /media
28.06.16 12:57:28 [-0400] mount.sh ending
```

If you boot without a card inserted, you will see:

```
28.06.16 14:47:57 [-0400] Systemd init system enabled.
28.06.16 14:48:02 [-0400] mount.sh starting
28.06.16 14:48:02 [-0400] mount.sh unmounting /media
28.06.16 14:48:03 [-0400] mount.sh mounting sc card to /media
28.06.16 14:48:03 [-0400] mount: special device /dev/mmcblk0p1 does not exist
28.06.16 14:48:03 [-0400] mount.sh ending
```  


###Check 

Terminal into the device and run:

```
root@beaglebone-add648:/data# df -h | grep File && df -h | grep mmcblk0                                                                                                                                                
```

You should see

```
Filesystem      Size  Used Avail Use% Mounted on                                                                                  
/dev/mmcblk0p1   15G   17M   15G   1% /media  
```

## Troubleshooting

If you don't see the volume:

Check to see that var INITSYSTEM is set to 'on'

```
root@beaglebone-add648:/# echo $INITSYSTEM     
```

You should see:

```                                     
on
```

If you don't see 'on' make sure you are running the Mount Up app.  This variable is set in the dockerfile.

Still don't see volume? Check that udev is running

```
ps -aux | grep udevd
```

You should see

```
root        78  0.0  0.4  10620  2236 ?        Ss   18:48   0:00 /lib/systemd/systemd-udevd   
```


## Notes

### Mounting to /data versus /media

In my tests, when mounted to /data 'Purge' does not delete data on the sd card.

Also, when mounted to the /data dir, the data is persistent across apps.  



### Naming

The onboard memory and the sdcard are both named dynamically on boot.  So I believe mmcblk06 is short for: multimedia card block zero partition 6.  

If you boot with out an sd card, and do df -h you will see 

```
Filesystem      Size  Used Avail Use% Mounted on                                                                                  
/dev/mmcblk0p6  1.4G  875M  192M  83% / 
```

The onboard memory mounted to root is dynamically named mmcblk06.  This is because it was the first memory seen by the system on boot.


If you then insert a micro sd chip, it will be named like
mmcblk16.  The zero changes to 1 because this volume was seen after the zero volume.

However, when you boot with the sdcard inserted, the system checks the sd card slot first, and when it sees the volume, it names it mmcblk0p1.  Then the onboard memory is named mmcblk1p6.