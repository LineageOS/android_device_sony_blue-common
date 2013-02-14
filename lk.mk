LOCAL_PATH := $(call my-dir)

include bootable/bootloader/lk/AndroidBoot.mk

INSTALLED_LK_BOOTLOADER_TARGET := $(PRODUCT_OUT)/lk.elf
MKELF := device/sony/blue-common/tools/mkelf.py

$(INSTALLED_LK_BOOTLOADER_TARGET): $(TARGET_EMMC_BOOTLOADER)
	$(hide) python $(MKELF) -o $(INSTALLED_LK_BOOTLOADER_TARGET) $(EMMC_BOOTLOADER_OUT)/build-msm8960/lk.bin@0x80208000 vendor/sony/blue-common/proprietary/boot/RPM.bin@0x20000,rpm

.PHONY: lk
lk: $(INSTALLED_LK_BOOTLOADER_TARGET)
