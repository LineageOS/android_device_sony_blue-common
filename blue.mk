$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_eu_supl.mk)

COMMON_PATH := device/sony/blue-common

DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:system/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml

# Ramdisk
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/prebuilt/mr:root/sbin/mr \
    $(COMMON_PATH)/prebuilt/logo_X.rle:root/logo.rle \
    $(COMMON_PATH)/config/fstab.sony:root/fstab.sony \
    $(COMMON_PATH)/config/fstab_sd.sony:root/fstab_sd.sony \
    $(COMMON_PATH)/config/init.netconfig.sh:system/etc/init.netconfig.sh \
    $(COMMON_PATH)/config/init.qcom-etc.rc:root/init.qcom-etc.rc \
    $(COMMON_PATH)/config/init.qcom.bt.sh:system/etc/init.qcom.bt.sh \
    $(COMMON_PATH)/config/init.qcom.efs.sync.sh:system/etc/init.qcom.efs.sync.sh \
    $(COMMON_PATH)/config/init.qcom.class_core.sh:root/init.qcom.class_core.sh \
    $(COMMON_PATH)/config/init.qcom.class_main.sh:root/init.qcom.class_main.sh \
    $(COMMON_PATH)/config/init.qcom.coex.sh:system/etc/init.qcom.coex.sh \
    $(COMMON_PATH)/config/init.qcom.fm.sh:system/etc/init.qcom.fm.sh \
    $(COMMON_PATH)/config/init.qcom.modem_links.sh:system/etc/init.qcom.modem_links.sh \
    $(COMMON_PATH)/config/init.qcom.post_boot.sh:system/etc/init.qcom.post_boot.sh \
    $(COMMON_PATH)/config/init.qcom.usb.rc:root/init.qcom.usb.rc \
    $(COMMON_PATH)/config/init.qcom.usb.sh:root/init.qcom.usb.sh \
    $(COMMON_PATH)/config/init.sony.rc:root/init.sony.rc \
    $(COMMON_PATH)/config/ueventd.sony.rc:root/ueventd.sony.rc

# Script for fixing perms on internal sdcard
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/prebuilt/fix_storage_permissions.sh:system/bin/fix_storage_permissions.sh

# Post recovery script
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/recovery/postrecoveryboot.sh:recovery/root/sbin/postrecoveryboot.sh

# CNE config
PRODUCT_COPY_FILES += \
   $(COMMON_PATH)/config/OperatorPolicy.xml:system/etc/OperatorPolicy.xml \
   $(COMMON_PATH)/config/UserPolicy.xml:system/etc/UserPolicy.xml

# Audio
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/audio_policy.conf:system/etc/audio_policy.conf \
    $(COMMON_PATH)/config/media_codecs.xml:system/etc/media_codecs.xml \
    $(COMMON_PATH)/config/snd_soc_msm_2x:system/etc/snd_soc_msm/snd_soc_msm_2x

# Thermal monitor configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/thermald.conf:system/etc/thermald.conf

# GPS
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/prebuilt/gps.conf:system/etc/gps.conf

# EGL config
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/egl.cfg:system/lib/egl/egl.cfg

# WPA supplicant config
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/config/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf  

# NFC Support
PRODUCT_PACKAGES += \
    libnfc \
    libnfc_jni \
    Nfc \
    Tag \
    com.android.nfc_extras

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/com.android.nfc_extras.xml:system/etc/permissions/com.android.nfc_extras.xml

# NFCEE access control
ifeq ($(TARGET_BUILD_VARIANT),user)
    NFCEE_ACCESS_PATH := $(COMMON_PATH)/config/nfcee_access.xml
else
    NFCEE_ACCESS_PATH := $(COMMON_PATH)/config/nfcee_access_debug.xml
endif
PRODUCT_COPY_FILES += \
    $(NFCEE_ACCESS_PATH):system/etc/nfcee_access.xml

# QCOM Display
PRODUCT_PACKAGES += \
    copybit.msm8960 \
    gralloc.msm8960 \
    hwcomposer.msm8960 \
    libgenlock \
    libmemalloc \
    liboverlay \
    libqdutils \
    libtilerenderer

# Audio
PRODUCT_PACKAGES += \
    audio.a2dp.default \
    audio_policy.msm8960 \
    audio.primary.msm8960 \
    libaudioutils \
    tinymix

# Omx
PRODUCT_PACKAGES += \
    libdivxdrmdecrypt \
    libI420colorconvert \
    libmm-omxcore \
    libOmxCore \
    libOmxVdec \
    libOmxVenc \
    libOmxAacEnc \
    libOmxAmrEnc \
    libOmxEvrcEnc \
    libOmxQcelp13Enc \
    libstagefrighthw \
    libstagefright_client

# GPS
PRODUCT_PACKAGES += \
    gps.msm8960

# Light
PRODUCT_PACKAGES += \
    lights.msm8960

# Power
PRODUCT_PACKAGES += \
    power.msm8960

# QRNGD
PRODUCT_PACKAGES += \
    qrngd

# WIFI MAC update
PRODUCT_PACKAGES += \
    mac-update

# Misc
PRODUCT_PACKAGES += \
    com.android.future.usb.accessory \
    XperiaSettings

# Live Wallpapers
PRODUCT_PACKAGES += \
    LiveWallpapers \
    LiveWallpapersPicker \
    VisualizationWallpapers \
    librs_jni

# Filesystem management tools
PRODUCT_PACKAGES += \
    make_ext4fs \
    setup_fs

# We have enough storage space to hold precise GC data
PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

# Set default USB interface
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp

# QCOM
PRODUCT_PROPERTY_OVERRIDES += \
    com.qc.hardware=true \
    dev.pm.dyn_samplingrate=1

# QC Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=/system/lib/libqc-opt.so

# Radio and Telephony
PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.ril_class=SonyQualcommRIL \
    ro.telephony.ril.v3=skipnullaid,skippinpukcount \
    rild.libpath=/system/lib/libril-qc-qmi-1.so \
    rild.libargs=-d /dev/smd0 \
    persist.rild.nitz_plmn= \
    persist.rild.nitz_long_ons_0= \
    persist.rild.nitz_long_ons_1= \
    persist.rild.nitz_long_ons_2= \
    persist.rild.nitz_long_ons_3= \
    persist.rild.nitz_short_ons_0= \
    persist.rild.nitz_short_ons_1= \
    persist.rild.nitz_short_ons_2= \
    persist.rild.nitz_short_ons_3= \
    ril.subscription.types=NV,RUIM \
    DEVICE_PROVISIONED=1 \
    keyguard.no_require_sim=1 \
    ro.use_data_netmgrd=true \
    ro.ril.transmitpower=true \
    ro.telephony.call_ring.multiple=false \
    persist.cne.UseCne=vendor \
    persist.cne.UseSwim=false \
    persist.cne.bat.range.low.med=30 \
    persist.cne.bat.range.med.high=60 \
    persist.cne.loc.policy.op=/system/etc/OperatorPolicy.xml \
    persist.cne.loc.policy.user=/system/etc/UserPolicy.xml \
    persist.cne.bwbased.rat.sel=false \
    persist.cne.snsr.based.rat.mgt=false \
    persist.cne.bat.based.rat.mgt=false \
    persist.cne.rat.acq.time.out=30000 \
    persist.cne.rat.acq.retry.tout=0 \
    persist.cne.nsrm.mode=false \
    persist.gps.qmienabled=true

# QCOM Display
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.hw=1 \
    debug.egl.hw=1 \
    debug.enabletr=true \
    debug.composition.type=dyn \
    debug.mdpcomp.maxlayer=3 \
    debug.mdpcomp.logs=0 \
    ro.hwui.text_cache_width=2048

# Audio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.audio.fluence.mode=endfire \
    persist.audio.vr.enable=false \
    persist.audio.handset.mic=analog \
    persist.audio.hp=true

# Audio LPA
PRODUCT_PROPERTY_OVERRIDES += \
    lpa.decode=true \
    lpa.use-stagefright=true

# Bluetooth
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qualcomm.bluetooth.sap=true \
    ro.qualcomm.bt.hci_transport=smd \
    ro.bluetooth.request.master=true \
    ro.bluetooth.remote.autoconnect=true

# OpenglES
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=131072

# Wifi
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=30
