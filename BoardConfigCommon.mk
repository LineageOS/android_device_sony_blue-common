TARGET_SPECIFIC_HEADER_PATH := device/sony/blue-common/include

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_HAS_NO_MISC_PARTITION := true

#kernel properties
TARGET_KERNEL_SOURCE := kernel/sony/msm8960

# Platform
TARGET_BOOTLOADER_BOARD_NAME := blue
TARGET_BOARD_PLATFORM := msm8960
TARGET_BOARD_PLATFORM_GPU := qcom-adreno200

# Architecture
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_ARCH_VARIANT_CPU := cortex-a9
TARGET_CPU_SMP := true

# Flags

COMMON_GLOBAL_CFLAGS += -DQCOM_HARDWARE

# Krait optimizations
TARGET_USE_KRAIT_BIONIC_OPTIMIZATION := true
TARGET_USE_KRAIT_PLD_SET := true
TARGET_KRAIT_BIONIC_PLDOFFS := 10
TARGET_KRAIT_BIONIC_PLDTHRESH := 10
TARGET_KRAIT_BIONIC_BBTHRESH := 64
TARGET_KRAIT_BIONIC_PLDSIZE := 64

# Kernel information
BOARD_KERNEL_CMDLINE := # This is ignored by sony's bootloader
BOARD_KERNEL_BASE := 0x40200000
BOARD_RECOVERY_BASE := 0x40200000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_FORCE_RAMDISK_ADDRESS := 0x41200000

# Wifi related defines
BOARD_WLAN_DEVICE                := bcmdhd
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_bcmdhd
WIFI_DRIVER_FW_PATH_STA          := "/vendor/firmware/fw_bcmdhd.bin"
WIFI_DRIVER_FW_PATH_AP           := "/vendor/firmware/fw_bcmdhd_apsta.bin"
WIFI_DRIVER_FW_PATH_P2P          := "/vendor/firmware/fw_bcmdhd_p2p.bin"
WIFI_DRIVER_FW_PATH_PARAM        := "/sys/module/bcmdhd/parameters/firmware_path"

# Graphics
USE_OPENGL_RENDERER := true
TARGET_USES_ION := true
TARGET_USES_C2D_COMPOSITION := true
BOARD_EGL_CFG := device/sony/blue-common/config/egl.cfg

CAMERA_USES_SURFACEFLINGER_CLIENT_STUB := true

TARGET_PROVIDES_LIBLIGHTS := true

# Camera
COMMON_GLOBAL_CFLAGS += -DICS_CAMERA_BLOB
BOARD_NEEDS_MEMORYHEAPPMEM := true

# QCOM hardware
BOARD_USES_QCOM_HARDWARE := true

# GPS
BOARD_USES_QCOM_GPS := true
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := sony
BOARD_VENDOR_QCOM_GPS_LOC_API_AMSS_VERSION := 50000

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
TARGET_NEEDS_BLUETOOTH_INIT_DELAY := true
TARGET_CUSTOM_BLUEDROID := ../../../device/sony/blue-common/bluedroid/bluetooth.c

# Webkit
ENABLE_WEBGL := true

# Custom boot
TARGET_RECOVERY_PIXEL_FORMAT := "BGRX_8888"
TARGET_RECOVERY_PRE_COMMAND := "touch /cache/recovery/boot;sync;"
BOARD_CUSTOM_BOOTIMG_MK := device/sony/blue-common/custombootimg.mk
TARGET_RELEASETOOL_OTA_FROM_TARGET_SCRIPT := device/sony/blue-common/releasetools/sony_ota_from_target_files
#BOARD_CUSTOM_GRAPHICS := ../../../device/sony/blue-common/recovery/recovery-gfx.c
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../device/sony/blue-common/recovery/recovery-keys.c
BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_15x24.h\"

TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/platform/msm_hsusb/gadget/lun%d/file

# Audio
#COMMON_GLOBAL_CFLAGS += -DQCOM_ACDB_ENABLED -DQCOM_VOIP_ENABLED
#BOARD_HAVE_SONY_AUDIO := true
#BOARD_HAVE_BACK_MIC_CAMCORDER := true
#BOARD_USE_QCOM_LPA := true

# Light Sensor
#BOARD_SYSFS_LIGHT_SENSOR := /sys/class/leds/lcd-backlight/als/enable
