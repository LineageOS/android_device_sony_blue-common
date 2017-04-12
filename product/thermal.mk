# Thermal configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/thermald.conf:system/etc/thermald.conf \
    $(COMMON_PATH)/configs/thermanager.xml:system/etc/thermanager.xml

# Thermal management packages
PRODUCT_PACKAGES += \
    thermanager
