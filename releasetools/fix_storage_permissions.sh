#!/sbin/sh

# Create mountpoint for internal sdcard
mkdir -p /storage/sdcard0

# Mount internal sdcard if needed
if ! mount | grep "on /storage/sdcard0 type" > /dev/null
then
    mount -t auto /dev/block/mmcblk0p15 /storage/sdcard0
fi

# Fix permissions on internal sdcard
chown root:1023 /storage/sdcard0
find /storage/sdcard0 -user 2800 -exec chown 1023:1023 {} \;

# Unmount internal sdcard if needed
if mount | grep "on /storage/sdcard0 type" > /dev/null
then
    umount -l /storage/sdcard0
fi
