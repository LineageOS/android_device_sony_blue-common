#!/system/bin/sh
#
# Storage layout migration script from mr0 to mr1
#

if [ ! -f /data/.layout_version ]; then

    # write layout version
    echo 2 > /data/.layout_version
    
    # remove lost+found
    rm -rf /data/media/lost+found

    # create list of files to migrate
    ls -a /data/media > /data/.media_contents

    # create new layout
    mkdir -p /data/media/0
    chown media_rw /data/media/0
    chgrp media_rw /data/media/0
    mkdir -p /data/media/legacy
    chown media_rw /data/media/legacy
    chgrp media_rw /data/media/legacy
    mkdir -p /data/media/obb
    chown media_rw /data/media/obb
    chgrp media_rw /data/media/obb

    # move all files to new layout
    while read line; do
        if [ "$(line)" != '.' ] || [ "$(line)" != '..' ]; then
            echo "Migrating ${line}"
            mv /data/media/${line} /data/media/0/
        fi
    done < /data/.media_contents

    # remove filelist
    rm /data/.media_contents

fi
