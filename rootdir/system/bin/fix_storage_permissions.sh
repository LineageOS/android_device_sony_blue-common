#!/sbin/sh
# Fix permissions on internal sdcard
find /sdcard -user 1023 -exec chown 2800:2800 {} \;
# Fix SELinux context labelling on internal sdcard
find /sdcard -user 2800 -exec chcon u:object_r:system_data_file:s0 {} \;
