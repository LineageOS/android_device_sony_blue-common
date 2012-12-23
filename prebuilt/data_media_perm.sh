#!/sbin/sh
# Attempt to restore stock permissions

find /sdcard -user 1023 -exec chown 2800:2800 {} \;
