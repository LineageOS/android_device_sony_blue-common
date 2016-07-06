# Audio configurations
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/audio/audio_effects.conf:system/vendor/etc/audio_effects.conf \
    $(COMMON_PATH)/audio/audio_platform_info.xml:system/etc/audio_platform_info.xml \
    $(COMMON_PATH)/audio/audio_policy.conf:system/etc/audio_policy.conf \
    $(COMMON_PATH)/audio/mixer_paths.xml:system/etc/mixer_paths.xml

# Audio properties
PRODUCT_PROPERTY_OVERRIDES += \
    audio.offload.disable=1 \
    mm.enable.smoothstreaming=true \
    ro.qc.sdk.audio.fluencetype=none \
    persist.audio.fluence.voicecall=true \
    persist.audio.fluence.voicerec=false \
    persist.audio.fluence.speaker=true \
    qcom.hw.aac.encoder=true
