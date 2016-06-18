# Platform permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml

# Ramdisk packages
PRODUCT_PACKAGES += \
    fstab.qcom \
    init.qcom.rc \
    ueventd.qcom.rc

# Storage package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/releasetools/fix_storage_permissions.sh:install/bin/fix_storage_permissions.sh

# TrimAreaDaemon package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/sbin/tad_static:root/sbin/tad_static

# Storage properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vold.primary_physical=1
