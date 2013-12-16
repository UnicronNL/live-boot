#!/bin/sh

#set -e

Vyos ()
{

# live-initramfs header

	. /scripts/functions
	. /lib/live/boot/9990-initramfs-tools.sh

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


unioncfgpath="$(trim_path /root/lib/live/mount/medium/${PERSISTENCE_PATH}/live-rw)"

if [ -d /root/opt/vyatta/etc/config ]
then
    if [ -z "${PERSISTENCE_PATH}" ]
    then
        return
    else
        if [ -f ${unioncfgpath}/opt/vyatta/etc/config/.configured ]
        then
          log_begin_msg "${unioncfgpath}..."
          mount -o bind ${unioncfgpath}/opt/vyatta/etc/config /root/opt/vyatta/etc/config
          log_end_msg
        elif [ -d /root/media/floppy/config ]
        then
          log_begin_msg "Using /root/media/floppy/config..."
          mount -o bind /root/media/floppy/config /root/opt/vyatta/etc/config
          log_end_msg
        else
          log_begin_msg "Creating ${unioncfgpath}..."
          cp -a /root/opt/vyatta/etc/config ${unioncfgpath}/opt/vyatta/etc >/dev/null 2>&1
          mount -o bind ${unioncfgpath}/opt/vyatta/etc/config /root/opt/vyatta/etc/config
          touch /root/opt/vyatta/etc/config/.configured
          log_end_msg
        fi
    fi
fi
}

