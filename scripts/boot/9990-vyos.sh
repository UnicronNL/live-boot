#!/bin/sh

#set -e

# initramfs-tools header
vyos ()
{

# live-initramfs header

	. /scripts/functions

# live-initramfs script

# try floppy
# if we do not discover an fd device, try loading the floppy module
grep -q fd /proc/devices || modprobe -q floppy 2>/dev/null
if grep -q fd /proc/devices
then
    mkdir -p /root/media/floppy
    mount /dev/fd0 /root/media/floppy -o sync,noatime,noexec,nosuid,nodev
fi 2>/dev/null

# bind the vyatta config directory with the following precedence
#	1) backing store if present
#	2) floppy if present
#	3) create live/"overlay" which may or maynot be on a non-volatile device
#	   but is certainly read-write

if [ -d /root/opt/vyatta/etc/config ]
then
    if [ -d /root/lib/live/mount/overlay/config ]
    then
      log_begin_msg "Using /lib/live/mount/overlay/config..."
      mount -o bind /root/lib/live/mount/overlay/config /root/opt/vyatta/etc/config
      log_end_msg
    elif [ -d /root/media/floppy/config ]
    then
      log_begin_msg "Using /root/media/floppy/config..."
      mount -o bind /root/media/floppy/config /root/opt/vyatta/etc/config
      log_end_msg
    else
      log_begin_msg "Creating /lib/live/mount/overlay/config..."
      cp -a /root/opt/vyatta/etc/config /root/lib/live/mount/overlay
      mount -o bind /root/lib/live/mount/overlay/config /root/opt/vyatta/etc/config
      log_end_msg
    fi
fi


# Local Variables:
# mode: shell-script
# sh-indentation: 4
# End:
}
