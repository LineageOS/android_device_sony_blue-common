# Copyright (C) 2015 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET_SPECIFIC_HEADER_PATH += device/sony/blue-common/include

# Architecture
TARGET_ARCH := arm
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := krait

# Kernel properties
TARGET_KERNEL_SOURCE := kernel/sony/msm8x60

# Platform
BOARD_VENDOR := sony
BOARD_VENDOR_PLATFORM := blue
TARGET_BOARD_PLATFORM := msm8960
TARGET_BOOTLOADER_BOARD_NAME := MSM8960

# Kernel information
BOARD_KERNEL_CMDLINE := # Ignored, see cmdline.txt
BOARD_KERNEL_BASE := 0x80200000
BOARD_RECOVERY_BASE := 0x80200000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01700000

# Partitions informations
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x01400000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x01400000
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1056964608
BOARD_USERDATAIMAGE_PARTITION_SIZE := 2147483648

# Partition settings
BOARD_FLASH_BLOCK_SIZE := 131072

# Bionic
MALLOC_IMPL := dlmalloc

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_QCOM := true
BLUETOOTH_HCI_USE_MCT := true

# Board overrides
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Camera
TARGET_PROVIDES_CAMERA_HAL := true

# Display HAL
TARGET_USES_ION := true
TARGET_USES_C2D_COMPOSITION := true

# Lights HAL
TARGET_PROVIDES_LIBLIGHT := true

# Power HAL
TARGET_POWERHAL_VARIANT := qcom
CM_POWERHAL_EXTENSION := qcom

# QCOM hardware
BOARD_USES_QCOM_HARDWARE := true

# Use legacy MMAP for pre-lollipop blobs
BOARD_USES_LEGACY_MMAP := true

# Time
BOARD_USES_QC_TIME_SERVICES := true

# Dumpstate
BOARD_LIB_DUMPSTATE := libdumpstate.sony

# Wifi
BOARD_HAS_QCOM_WLAN              := true
BOARD_WLAN_DEVICE                := qcwcn
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_DRIVER_MODULE_PATH          := "/system/lib/modules/wlan.ko"
WIFI_DRIVER_MODULE_NAME          := "wlan"
WIFI_DRIVER_FW_PATH_STA          := "sta"
WIFI_DRIVER_FW_PATH_AP           := "ap"

BOARD_USE_SONY_MACUPDATE := true

# Camera
USE_DEVICE_SPECIFIC_CAMERA := true

# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := $(TARGET_BOARD_PLATFORM)
BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true
TARGET_NO_RPC := true

# RIL
BOARD_PROVIDES_LIBRIL := true
BOARD_RIL_CLASS := ../../../device/sony/blue-common/ril/

# Needed for blobs
TARGET_RELEASE_CPPFLAGS += -DNEEDS_VECTORIMPL_SYMBOLS

# Custom boot
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := device/sony/blue-common/custombootimg.mk
TARGET_RELEASETOOLS_EXTENSIONS := device/sony/blue-common

# Recovery
BOARD_HAS_NO_SELECT_BUTTON := true
TARGET_RECOVERY_FSTAB := device/sony/blue-common/rootdir/fstab.qcom
TARGET_USERIMAGES_USE_EXT4 := true

# Audio
AUDIO_FEATURE_ENABLED_INCALL_MUSIC := false
AUDIO_FEATURE_ENABLED_COMPRESS_VOIP := false
BOARD_USES_ALSA_AUDIO := true
BOARD_USES_LEGACY_ALSA_AUDIO := true
TARGET_USES_QCOM_COMPRESSED_AUDIO := true
BOARD_HAVE_NEW_QCOM_CSDCLIENT := true
QCOM_CSDCLIENT_ENABLED := false

# Sensors
SOMC_CFG_SENSORS := true
SOMC_CFG_SENSORS_LIGHT_AS3676 := yes
SOMC_CFG_SENSORS_LIGHT_AS3676_PATH := "/sys/devices/i2c-10/10-0040"
SOMC_CFG_SENSORS_GYRO_MPU3050 := yes
SOMC_CFG_SENSORS_PROXIMITY_APDS9702 := yes
SOMC_CFG_SENSORS_ACCEL_BMA250NA_INPUT := yes
SOMC_CFG_SENSORS_COMPASS_AK8972 := yes

# Include common SE policies
include device/qcom/sepolicy/sepolicy.mk

BOARD_SEPOLICY_DIRS += device/sony/blue-common/sepolicy

# inherit from the proprietary version
-include vendor/sony/blue-common/BoardConfigVendor.mk
