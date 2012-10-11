LOCAL_MODULE := wiperiface
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_SUFFIX := -timestamp
LOCAL_PATH := $(call my-dir)

#include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): WIPERIFACE := wiperiface_v02
$(LOCAL_BUILT_MODULE): SYMLINK := $(TARGET_OUT)/bin/wiperiface
$(LOCAL_BUILT_MODULE): $(LOCAL_PATH)/Android.mk
$(LOCAL_BUILT_MODULE):
	$(hide) echo "Symlink: $(SYMLINK) -> $(WIPERIFACE)"
	$(hide) mkdir -p $(dir $@)
	$(hide) mkdir -p $(dir $(SYMLINK))
	$(hide) rm -rf $@
	$(hide) rm -rf $(SYMLINK)
	$(hide) ln -sf $(WIPERIFACE) $(SYMLINK)
	$(hide) touch $@
