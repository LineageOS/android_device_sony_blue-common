#!/sbin/sh
# Fix permissions on internal sdcard
# to properly interoperate with Sony
# firmware
find /sdcard -user 1023 -exec chown 2800:2800 {} \;
