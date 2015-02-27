#!/sbin/sh

# Mount internal sdcard
mount -t auto /dev/block/mmcblk0p15 /storage/sdcard0

# Fix permissions on internal sdcard
chown root:1023 /storage/sdcard0
find /storage/sdcard0 -user 2800 -exec chown 1023:1023 {} \;

# Unmount internal sdcard
umount -l /storage/sdcard0
