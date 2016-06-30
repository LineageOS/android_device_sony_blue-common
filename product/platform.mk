# Ramdisk packages
PRODUCT_PACKAGES += \
    fstab.qcom \
    init.qcom.rc \
    ueventd.qcom.rc

# Storage package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/releasetools/fix_storage_permissions.sh:install/bin/fix_storage_permissions.sh

# Sony TrimArea package
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/sbin/tad_static:root/sbin/tad_static

# Sony MAC-Update package
PRODUCT_PACKAGES += \
    mac-update \

# Storage properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vold.primary_physical=1
