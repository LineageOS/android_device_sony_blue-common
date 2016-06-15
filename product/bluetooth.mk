# Bluetooth permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml

# Bluetooth configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/etc/init.sony.bt.sh:system/etc/init.sony.bt.sh

# Bluetooth packages
PRODUCT_PACKAGES += \
    hci_qcomm_init

# Bluetooth properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qualcomm.bt.hci_transport=smd
