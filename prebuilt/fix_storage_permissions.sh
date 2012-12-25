#!/sbin/sh
# Fix permissions on internal sdcard
find /sdcard -user 2800 -exec chown 1023:1023 {} \;
