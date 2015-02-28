#!/system/bin/sh

# Mount internal sdcard
mount -t auto /dev/block/mmcblk0p15 /mnt/media_rw/sdcard0

# Fix permissions on internal sdcard
chown 1023:1023 /mnt/media_rw/sdcard0
find /mnt/media_rw/sdcard0 -user 2800 -exec chown 1023:1023 {} \;

# Unmount internal sdcard
umount -l /mnt/media_rw/sdcard0

exit 0
