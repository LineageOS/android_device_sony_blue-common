# QCOM legacy sepolicies
include device/qcom/sepolicy-legacy/sepolicy.mk

# Common sepolicies
BOARD_SEPOLICY_DIRS += \
    $(COMMON_PATH)/sepolicy

# LineageOS common sepolicies
ifeq ($(BOARD_AOSP_BASED),)
BOARD_SEPOLICY_DIRS += \
    $(COMMON_PATH)/sepolicy-lineage
endif
