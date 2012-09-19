LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_BOOTLOADER_BOARD_NAME),blue)
    include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
