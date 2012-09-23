#!/system/bin/sh
# Copyright (c) 2009-2012, Code Aurora Forum. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Code Aurora nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`

#
# Function to start sensors for DSPS enabled platforms
#
start_sensors()
{
    mkdir -p /data/system/sensors
    touch /data/system/sensors/settings
    chown system.system /data/system
    chmod 775 /data/system
    chmod 775 /data/system/sensors
    chmod 664 /data/system/sensors/settings

    mkdir -p /data/misc/sensors
    chmod 775 /data/misc/sensors

    if [ ! -s /data/system/sensors/settings ]; then
        # If the settings file is empty, enable sensors HAL
        # Otherwise leave the file with it's current contents
        echo 1 > /data/system/sensors/settings
    fi
    start sensors
}

baseband=`getprop ro.baseband`

#
# Suppress default route installation during RA for IPV6; user space will take
# care of this
#
for file in /proc/sys/net/ipv6/conf/*
do
  echo 0 > $file/accept_ra_defrtr
done

#
# Update USB serial number if passed from command line
#
serialnum=`getprop ro.serialno`
case "$serialnum" in
    "") ;; #Do nothing, use default serial number or check for persist one below
    * )
    echo "$serialnum" > /sys/class/android_usb/android0/iSerial
esac

#
# Allow unique persistent serial numbers for devices connected via usb
# User needs to set unique usb serial number to persist.usb.serialno
#
serialno=`getprop persist.usb.serialno`
case "$serialno" in
    "") ;; #Do nothing here
    * )
    echo "$serialno" > /sys/class/android_usb/android0/iSerial
esac

#
# Allow persistent usb charging disabling
# User needs to set usb charging disabled in persist.usb.chgdisabled
#
target=`getprop ro.board.platform`
usbchgdisabled=`getprop persist.usb.chgdisabled`
case "$usbchgdisabled" in
    "") ;; #Do nothing here
    * )
    case $target in
        "msm8660")
        echo "$usbchgdisabled" > /sys/module/pmic8058_charger/parameters/disabled
        echo "$usbchgdisabled" > /sys/module/smb137b/parameters/disabled
	;;
        "msm8960")
        echo "$usbchgdisabled" > /sys/module/pm8921_charger/parameters/disabled
	;;
    esac
esac

#
# Allow USB enumeration with default PID/VID
#
echo 1  > /sys/class/android_usb/f_mass_storage/lun/nofua
usb_config=`getprop persist.sys.usb.config`
case "$usb_config" in
    "" | "adb") #USB persist config not set, select default configuration
        case $target in
            "msm8960")
                socid=`cat /sys/devices/system/soc/soc0/id`
                case "$socid" in
                    "109")
                         setprop persist.sys.usb.config diag,adb
                    ;;
                    *)
                        case "$baseband" in
                            "mdm")
                                 setprop persist.sys.usb.config diag,diag_mdm,serial_hsic,serial_tty,rmnet_hsic,mass_storage,adb
                            ;;
                            *)
                                 setprop persist.sys.usb.config diag,serial_smd,serial_tty,rmnet_bam,mass_storage,adb
                            ;;
                        esac
                    ;;
                esac
            ;;
            "msm7627a")
                setprop persist.sys.usb.config diag,serial_smd,serial_tty,rmnet_smd,mass_storage,adb
            ;;
            * )
                case "$baseband" in
                    "svlte2a")
                         setprop persist.sys.usb.config diag,diag_mdm,serial_sdio,serial_smd,rmnet_smd_sdio,mass_storage,adb
                    ;;
                    "csfb")
                         setprop persist.sys.usb.config diag,diag_mdm,serial_sdio,serial_tty,rmnet_sdio,mass_storage,adb
                    ;;
                    *)
                         setprop persist.sys.usb.config diag,serial_tty,serial_tty,rmnet_smd,mass_storage,adb
                    ;;
                esac
            ;;
        esac
    ;;
    * ) ;; #USB persist config exists, do nothing
esac

#
# Start gpsone_daemon for SVLTE Type I & II devices
#
case "$target" in
        "msm7630_fusion")
        start gpsone_daemon
esac
case "$baseband" in
        "svlte2a")
        start gpsone_daemon
        start bridgemgrd
esac
case "$target" in
        "msm7630_surf" | "msm8660" | "msm8960")
        start quipc_igsn
esac
case "$target" in
        "msm7630_surf" | "msm8660" | "msm8960")
        start quipc_main
esac

case "$target" in
    "msm7630_surf" | "msm7630_1x" | "msm7630_fusion")
        value=`cat /sys/devices/system/soc/soc0/hw_platform`
        case "$value" in
            "Fluid")
             start profiler_daemon;;
        esac
        ;;
    "msm8660" )
        platformvalue=`cat /sys/devices/system/soc/soc0/hw_platform`
        case "$platformvalue" in
            "Fluid")
                start_sensors
                start profiler_daemon;;
        esac
        chown root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
        chmod 220 /sys/devices/platform/msm_hsusb/gadget/wakeup
        ;;
    "msm7627a" )
        chown root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
        chmod 220 /sys/devices/platform/msm_hsusb/gadget/wakeup
        ;;
    "msm8960")
        case "$baseband" in
        "msm")
             start_sensors;;
        esac

        platformvalue=`cat /sys/devices/system/soc/soc0/hw_platform`
        case "$platformvalue" in
             "Fluid")
              start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac

        chown root.system /sys/devices/platform/msm_otg/msm_hsusb/gadget/wakeup
        chmod 220 /sys/devices/platform/msm_otg/msm_hsusb/gadget/wakeup
        ;;
    "msm7630_surf" )
        chown root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
        chmod 220 /sys/devices/platform/msm_hsusb/gadget/wakeup
        ;;

esac
