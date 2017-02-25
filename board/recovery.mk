# TWRP (Optional)
ifneq ($(WITH_TWRP),true)

# Recovery configurations
RECOVERY_FSTAB_VERSION := 2
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/rootdir/fstab.qcom

endif
