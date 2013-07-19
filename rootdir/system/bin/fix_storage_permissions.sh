#!/sbin/sh
# Fix permissions on internal sdcard
find /sdcard -user 1023 -exec chown 2800:2800 {} \;
# Fix SELinux context labelling on internal sdcard
# Not sure if sdcard_internal/external, and don't even tell me that this
# isn't the best way to do it - it's not, but currently there isn't any cleaner way.
find /sdcard -user 2800 -exec toolbox chcon u:object_r:sdcard_external:s0 {} \;
