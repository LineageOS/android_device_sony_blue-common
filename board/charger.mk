# Healthd
BOARD_CHARGER_ENABLE_SUSPEND := true
BOARD_CHARGER_DISABLE_INIT_BLANK := true
RED_LED_PATH := /sys/class/leds/pwr-red/brightness
GREEN_LED_PATH := /sys/class/leds/pwr-green/brightness
BLUE_LED_PATH := /sys/class/leds/pwr-blue/brightness

# Healthd library extension
BOARD_HEALTHD_CUSTOM_CHARGER_RES := $(COMMON_PATH)/charger/images
