LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_BOARD_CM),blue)
    include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
