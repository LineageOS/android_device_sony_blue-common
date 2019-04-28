# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8960

# Vendor platform
BOARD_VENDOR := sony
BOARD_VENDOR_PLATFORM := blue

# Legacy blobs
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true
TARGET_PROCESS_SDK_VERSION_OVERRIDE := \
    /system/bin/mediaserver=22 \
    /system/vendor/bin/hw/android.hardware.sensors@1.0-service=22

# Dumpstate
BOARD_LIB_DUMPSTATE := libdumpstate.sony

# Images
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Binder API
TARGET_USES_64_BIT_BINDER := true

# Shipping API
PRODUCT_SHIPPING_API_LEVEL := 14
