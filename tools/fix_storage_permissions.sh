#!/sbin/sh

# Fix permissions on internal sdcard
chown root:1023 /storage/sdcard0
find /storage/sdcard0 -user 2800 -exec chown 1023:1023 {} \;
