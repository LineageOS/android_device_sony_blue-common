$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_eu_supl.mk)

# Recovery resources
$(call inherit-product, device/sony/blue-common/recovery/recovery.mk)

DEVICE_PACKAGE_OVERLAYS += device/sony/blue-common/overlay

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

# Configuration scripts
PRODUCT_COPY_FILES += \
   device/sony/blue-common/prebuilt/logo_X.rle:root/logo.rle

# EGL config
PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/egl.cfg:system/lib/egl/egl.cfg

# Common Qualcomm scripts
PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/init.qcom.efs.sync.sh:system/etc/init.qcom.efs.sync.sh

PRODUCT_COPY_FILES += \
   device/sony/blue-common/config/fstab.sony:root/fstab.sony \
   device/sony/blue-common/config/fstab_sd.sony:root/fstab_sd.sony

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

# NFC Support
#PRODUCT_PACKAGES += \
#    libnfc \
#    libnfc_jni \
#    Nfc \
#    Tag \
#    com.android.nfc_extras

#PRODUCT_COPY_FILES += \
#    frameworks/native/data/etc/com.android.nfc_extras.xml:system/etc/permissions/com.android.nfc_extras.xml

# NFCEE access control
#ifeq ($(TARGET_BUILD_VARIANT),user)
#    NFCEE_ACCESS_PATH := device/sony/blue-common/config/nfcee_access.xml
#else
#    NFCEE_ACCESS_PATH := device/sony/blue-common/config/nfcee_access_debug.xml
#endif
#PRODUCT_COPY_FILES += \
#    $(NFCEE_ACCESS_PATH):system/etc/nfcee_access.xml

# Audio
PRODUCT_PACKAGES += \
    alsa.msm8960 \
    audio.a2dp.default \
    audio_policy.msm8960 \
    audio.primary.msm8960 \
    libaudioutils

PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/audio_policy.conf:system/etc/audio_policy.conf \
    device/sony/blue-common/config/media_codecs.xml:system/etc/media_codecs.xml

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
    com.android.future.usb.accessory

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

# Custom init / uevent
PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/init.sony.rc:root/init.sony.rc \
    device/sony/blue-common/config/init.qcom-etc.rc:root/init.qcom-etc.rc \
    device/sony/blue-common/config/init.qcom-root.rc:root/init.qcom-root.rc \
    device/sony/blue-common/config/init.qcom.class_core.sh:root/init.qcom.class_core.sh \
    device/sony/blue-common/config/init.qcom.class_main.sh:root/init.qcom.class_main.sh \
    device/sony/blue-common/config/init.qcom.sh:root/init.qcom.sh \
    device/sony/blue-common/config/ueventd.sony.rc:root/ueventd.sony.rc

# Recovery bootstrap script
PRODUCT_COPY_FILES += \
    device/sony/blue-common/recovery/bootrec:root/sbin/bootrec \
    device/sony/blue-common/recovery/postrecoveryboot.sh:root/sbin/postrecoveryboot.sh

# Additional sbin stuff
PRODUCT_COPY_FILES += \
    device/sony/blue-common/prebuilt/mr:root/sbin/mr

# CNE config
PRODUCT_COPY_FILES += \
   device/sony/blue-common/config/OperatorPolicy.xml:system/etc/OperatorPolicy.xml \
   device/sony/blue-common/config/UserPolicy.xml:system/etc/UserPolicy.xml

# condigs
PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/init.netconfig.sh:system/etc/init.netconfig.sh \
    device/sony/blue-common/config/init.qcom.bt.sh:system/etc/init.qcom.bt.sh \
    device/sony/blue-common/config/init.qcom.coex.sh:system/etc/init.qcom.coex.sh \
    device/sony/blue-common/config/init.qcom.fm.sh:system/etc/init.qcom.fm.sh \
    device/sony/blue-common/config/init.qcom.modem_links.sh:system/etc/init.qcom.modem_links.sh \
    device/sony/blue-common/config/init.qcom.post_boot.sh:system/etc/init.qcom.post_boot.sh \
    device/sony/blue-common/config/iddd.conf:system/etc/iddd.conf \
    device/sony/blue-common/config/sysmon.cfg:system/etc/sysmon.cfg

# ALSA configuration
PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/snd_soc_msm_2x:system/etc/snd_soc_msm/snd_soc_msm_2x

# Thermal monitor configuration
PRODUCT_COPY_FILES += \
    device/sony/blue-common/config/thermald.conf:system/etc/thermald.conf

# Set default USB interface
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp

#QCOM Display overrides
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.hw=1 \
    debug.egl.hw=1 \
    debug.composition.type=dyn \
    debug.mdpcomp.maxlayer=3 \
    debug.mdpcomp.logs=0

# Audio overrides
PRODUCT_PROPERTY_OVERRIDES += \
    persist.audio.fluence.mode=endfire \
    persist.audio.vr.enable=false \
    persist.audio.handset.mic=analog \
    persist.audio.hp=true 

#system prop for Bluetooth hci transport
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qualcomm.bt.hci_transport=smd \
    ro.bluetooth.request.master=true \
    ro.bluetooth.remote.autoconnect=true
