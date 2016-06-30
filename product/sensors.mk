# Sensors configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/sap.conf:system/etc/sap.conf

# Thermal configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/thermald.conf:system/etc/thermald.conf

# Sensors packages
PRODUCT_PACKAGES += \
    sensors.msm8960

# Sensors SHIM packages
PRODUCT_PACKAGES += \
    libshim_MPU3050
