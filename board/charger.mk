# Healthd
BOARD_CHARGER_ENABLE_SUSPEND := true
BOARD_CHARGER_DISABLE_INIT_BLANK := true
BACKLIGHT_PATH := /sys/devices/i2c-10/10-0040/leds/lcd-backlight_1/brightness
SECONDARY_BACKLIGHT_PATH := /sys/devices/i2c-10/10-0040/leds/lcd-backlight_2/brightness
BOARD_HEALTHD_CUSTOM_CHARGER_RES := $(COMMON_PATH)/charger/images
RED_LED_PATH := /sys/class/leds/pwr-red/brightness
GREEN_LED_PATH := /sys/class/leds/pwr-green/brightness
BLUE_LED_PATH := /sys/class/leds/pwr-blue/brightness
