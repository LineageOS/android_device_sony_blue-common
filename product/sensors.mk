# Sensors permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml

# Sensors configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/sap.conf:system/etc/sap.conf

# Thermal configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/thermald.conf:system/etc/thermald.conf \
    $(COMMON_PATH)/rootdir/etc/disable_msm_thermal.sh:system/etc/disable_msm_thermal.sh

# Sensors packages
PRODUCT_PACKAGES += \
    sensors.msm8960
