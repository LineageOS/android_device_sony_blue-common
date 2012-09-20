#!/system/bin/sh
# Copyright (c) 2011, Code Aurora Forum. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Code Aurora Forum, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#

# No path is set up at this point so we have to do it here.
PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH

cd /system/etc/firmware

case `ls modem_fw.mdt 2>/dev/null` in
    modem_fw.mdt)
        continue;;
    *)
    linksNeeded=1
    break;;
esac

# if links are needed mount the FS as read write
case $linksNeeded in
    1)
        mount -t ext4 -o remount,rw,barrier=0 /dev/block/mmcblk0p12 /system
        case `cat /sys/devices/system/soc/soc0/version 2>/dev/null` in
            "1.1")
                for file in modem_f1.* ; do
                    newname=modem_fw.${file##*.}
                    rm $newname 2>/dev/null
                    ln -s $file $newname
                done
                break;;
            *)
                for file in modem_f2.* ; do
                    newname=modem_fw.${file##*.}
                    rm $newname 2>/dev/null
                    ln -s $file $newname
                done
                break;;
        esac
        mount -t ext4 -o remount,ro,barrier=0 /dev/block/mmcblk0p12 /system
esac
