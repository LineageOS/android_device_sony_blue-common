/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2016 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* === Module Debug === */
#define LOG_NDEBUG 0
#define LOG_PARAM
// #define LOG_BRIGHTNESS
#define LOG_TAG "lights.blue"

/* === Module Libraries === */
#include <cutils/log.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#ifdef ENABLE_GAMMA_CORRECTION
#include <math.h>
#endif
#include <sys/ioctl.h>
#include <sys/types.h>
#include <hardware/lights.h>

/* === Module Header === */
#include "sony_lights.h"

/* === Module Paths === */
char const*const PWR_RED_USE_PATTERN_FILE = "/sys/devices/i2c-10/10-0040/leds/pwr-red/use_pattern";
char const*const PWR_GREEN_USE_PATTERN_FILE = "/sys/devices/i2c-10/10-0040/leds/pwr-green/use_pattern";
char const*const PWR_BLUE_USE_PATTERN_FILE = "/sys/devices/i2c-10/10-0040/leds/pwr-blue/use_pattern";
char const*const PWR_RED_BRIGHTNESS_FILE = "/sys/devices/i2c-10/10-0040/leds/pwr-red/brightness";
char const*const PWR_GREEN_BRIGHTNESS_FILE = "/sys/devices/i2c-10/10-0040/leds/pwr-green/brightness";
char const*const PWR_BLUE_BRIGHTNESS_FILE = "/sys/devices/i2c-10/10-0040/leds/pwr-blue/brightness";
char const*const PATTERN_DATA_FILE = "/sys/bus/i2c/devices/10-0040/pattern_data";
char const*const PATTERN_USE_SOFTDIM_FILE = "/sys/bus/i2c/devices/10-0040/pattern_use_softdim";
char const*const PATTERN_DURATION_SECS_FILE = "/sys/bus/i2c/devices/10-0040/pattern_duration_secs";
char const*const PATTERN_DELAY_FILE = "/sys/bus/i2c/devices/10-0040/pattern_delay";
char const*const DIM_TIME_FILE = "/sys/bus/i2c/devices/10-0040/dim_time";

/* === Module Variables === */
static pthread_once_t g_init = PTHREAD_ONCE_INIT;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;
static struct light_state_t g_notification;
static struct light_state_t g_battery;
#ifdef DEVICE_HAYABUSA
/* Needed for hayabusa logo lights */
int last_screen_brightness = 0;
#endif

/* === Module init_globals === */
void
init_globals(void) {
    /* Device mutex */
    pthread_mutex_init(&g_lock, NULL);
}

/* === Module write_int === */
static int
write_int(char const* path, int value) {

    int fd, amt, bytes;
    char buffer[20];

    /* Int output to path */
    fd = open(path, O_RDWR);
    if (fd >= 0) {
        bytes = snprintf(buffer, sizeof(buffer), "%d\n", value);
        amt = write(fd, buffer, bytes);
        close(fd);
        return (amt == -1 ? -errno : 0);
    }
    else {
        ALOGE("write_int failed to open %s\n", path);
        return -errno;
    }
}

/* === Module write_string === */
static int
write_string(char const* path, const char *value) {

    int fd, amt, bytes;
    char buffer[20];

    /* String output to path */
    fd = open(path, O_RDWR);
    if (fd >= 0) {
        bytes = snprintf(buffer, sizeof(buffer), "%s\n", value);
        amt = write(fd, buffer, bytes);
        close(fd);
        return (amt == -1 ? -errno : 0);
    }
    else {
        ALOGE("write_string failed to open %s\n", path);
        return -errno;
    }
}

/* === Module is_lit === */
static int
is_lit(struct light_state_t const* state) {
    return state->color & 0x00ffffff;
}

/* === Module rgb_to_brightness === */
static unsigned int
rgb_to_brightness(struct light_state_t const* state) {

    /* LCD brightness calculation */
    unsigned int color = state->color & 0x00ffffff;
    return ((77*((color>>16)&0x00ff))
            + (150*((color>>8)&0x00ff))
            + (29*(color&0x00ff))) >> 8;
}

/* === Module brightness_apply_gamma === */
#ifdef ENABLE_GAMMA_CORRECTION
static int
brightness_apply_gamma(int brightness) {

    double floatbrt = (double) brightness;

    /* Brightness to corrected brightness */
    floatbrt /= 255.0;
#ifdef LOG_BRIGHTNESS
    ALOGV("%s: brightness = %d, floatbrt = %f", __FUNCTION__, brightness,
            floatbrt);
#endif
    floatbrt = pow(floatbrt, 2.2);
#ifdef LOG_BRIGHTNESS
    ALOGV("%s: gamma corrected floatbrt = %f", __FUNCTION__, floatbrt);
#endif
    floatbrt *= 255.0;
    brightness = (int) floatbrt;
#ifdef LOG_BRIGHTNESS
    ALOGV("%s: gamma corrected brightness = %d", __FUNCTION__, brightness);
#endif
    return brightness;
}
#endif

/* === Module get_light_lcd_max_backlight === */
static int
get_light_lcd_max_backlight() {

    char value[6];
    int fd, len, max_brightness;

    /* Open the max brightness file */
    if ((fd = open(MAX_BRIGHTNESS_FILE, O_RDONLY)) < 0) {
        ALOGE("[%s]: Could not open max brightness file %s: %s", __FUNCTION__,
                MAX_BRIGHTNESS_FILE, strerror(errno));
        ALOGE("[%s]: Assume max brightness 255", __FUNCTION__);
        return 255;
    }

    /* Read the max brightness file */
    if ((len = read(fd, value, sizeof(value))) <= 1) {
        ALOGE("[%s]: Could not read max brightness file %s: %s", __FUNCTION__,
                MAX_BRIGHTNESS_FILE, strerror(errno));
        ALOGE("[%s]: Assume max brightness 255", __FUNCTION__);
        close(fd);
        return 255;
    }

    /* Extract the max brightness value */
    max_brightness = strtol(value, NULL, 10);
    close(fd);

    return (unsigned int) max_brightness;
}

/* === Module set_light_lcd_backlight === */
static int
set_light_lcd_backlight(struct light_device_t* dev,
        struct light_state_t const* state) {

    int err = 0;
    int brightness = rgb_to_brightness(state);
    int max_brightness = get_light_lcd_max_backlight();

    /* Process the brightness value */
    if (brightness > 0) {
#ifdef ENABLE_GAMMA_CORRECTION
        brightness = brightness_apply_gamma(brightness);
#endif
        brightness = (max_brightness * brightness) / 255;
        if (brightness < LCD_BRIGHTNESS_MIN) {
            brightness = LCD_BRIGHTNESS_MIN;
        }
    }

#ifdef LOG_BRIGHTNESS
    ALOGV("[%s] brightness %d max_brightness %d", __FUNCTION__, brightness,
            max_brightness);
#endif

    pthread_mutex_lock(&g_lock);
    err |= write_int (LCD_BACKLIGHT_FILE, brightness);
    err |= write_int (LCD_BACKLIGHT2_FILE, brightness);
#ifdef DEVICE_HAYABUSA
    if (brightness == 0 && is_lit(&g_notification)) {
        /* Apply logo brightness on display off */
        write_int(LOGO_BACKLIGHT_FILE, max_brightness);
        write_int(LOGO_BACKLIGHT2_FILE, max_brightness);
    } else {
        write_int(LOGO_BACKLIGHT_FILE, brightness);
        write_int(LOGO_BACKLIGHT2_FILE, brightness);
    }

    last_screen_brightness = brightness;
#endif
    pthread_mutex_unlock(&g_lock);

    (void)dev;
    return err;
}

/* === Module clear_lights_locked === */
static void
clear_lights_locked() {

    /* Clear all LEDs */
    write_string(PATTERN_DATA_FILE, "0");
    write_int(PATTERN_USE_SOFTDIM_FILE, 0);
    write_int(PATTERN_DURATION_SECS_FILE, 1);
    write_int(PATTERN_DELAY_FILE, 1);
    write_int(DIM_TIME_FILE, 500);
    write_int(PWR_RED_BRIGHTNESS_FILE, 0);
    write_int(PWR_RED_USE_PATTERN_FILE, 0);
    write_int(PWR_GREEN_BRIGHTNESS_FILE, 0);
    write_int(PWR_GREEN_USE_PATTERN_FILE, 0);
    write_int(PWR_BLUE_BRIGHTNESS_FILE, 0);
    write_int(PWR_BLUE_USE_PATTERN_FILE, 0);
#ifdef DEVICE_HAYABUSA
    write_int(LOGO_BACKLIGHT_FILE, last_screen_brightness);
    write_int(LOGO_BACKLIGHT2_FILE, last_screen_brightness);
    write_int(LOGO_BACKLIGHT_PATTERN_FILE, 0);
    write_int(LOGO_BACKLIGHT2_PATTERN_FILE, 0);
#endif
}

/* === Module get_light_leds_dim_time === */
static int
get_light_leds_dim_time(int offMS) {

    /* Get diming time from offMS */
    if (offMS > 500) return 500;
    else if (offMS > 190) return 190;
    else if (offMS > 95) return 95;
    else if (offMS > 50) return 50;
    else return 50;
}

/* === Module pattern_data_on_bit === */
static void
pattern_data_on_bit(double duration, int onMS, int offMS, int *data) {

    int bit, cycle, now_cycle, s;

    bit = 0;
    cycle = (int)(duration / (onMS + offMS) + 0.5);
    if (cycle == 0) cycle = 1;
    now_cycle = 0;
    s = 0;

    /* Transform settings to pattern data */
    for (bit = 0; bit < 32; ++bit) {
        for (now_cycle = 0; now_cycle < cycle; ++now_cycle) {
            s = duration / 32 * bit - now_cycle * (onMS + offMS);
            if (s >= 0 && s < onMS) {
                *data |= 1 << bit;
            }
        }
    }
}

/* === Module set_light_leds_locked === */
static int
set_light_leds_locked(struct light_device_t* dev,
        struct light_state_t const* state) {

    int alpha, red, green, blue;
    int flashMode;
    int onMS, offMS, totalMS;
    unsigned int colorRGB;
    int pattern_duration = 1, pattern_dim_time = 50, pattern_data_dec = 0,
            pattern_delay = 0, pattern_use_softdim = 0;
    char pattern_data[11];

    colorRGB = state->color;

    red = (colorRGB >> 16) & 0xFF;
    green = (colorRGB >> 8) & 0xFF;
    blue = colorRGB & 0xFF;
    flashMode = state->flashMode;

    /* Get the flashmode and disable it if always on */
    if (state->flashOffMS == 0) {
        flashMode = LIGHT_FLASH_NONE;
    }

    /* Set rendering values based on flashMode */
    switch (flashMode) {
        case LIGHT_FLASH_TIMED:
            onMS = state->flashOnMS;
            offMS = state->flashOffMS;
            pattern_use_softdim = 1;
            break;
        case LIGHT_FLASH_NONE:
        default:
            onMS = 0;
            offMS = 0;
            pattern_use_softdim = 0;
            break;
    }


#ifdef LOG_PARAM
    ALOGD("set_light_leds_locked mode %d, colorRGB=%08X, onMS=%d, offMS=%d\n",
            state->flashMode, colorRGB, onMS, offMS);
#endif

    /* Render with timings */
    if (onMS > 0 && offMS > 0) {
        if (onMS + offMS > 15000) {
            if (onMS > 8000) {
                onMS = 8000;
            }
            if (offMS > 15000 - onMS) {
                offMS = 15000 - onMS;
            }
        }

        totalMS = onMS + offMS;

        if (totalMS < 8000 && onMS < 1000) {
            pattern_duration = 1;
            pattern_dim_time = get_light_leds_dim_time(
                    offMS > onMS ? onMS : offMS);
            pattern_data_on_bit(1000.0, onMS, offMS, &pattern_data_dec);
            pattern_delay = totalMS - 1000 < 1000 ?
                (offMS > 3 * onMS ? 1 : 0) :
                (totalMS - 1000) / 1000;
            /* When offMS is 3 times longer than onMS (eg on 300ms, off 1000ms)
               if we only use pattern_data to describe off time (700ms)
               it will appear too short.
               (although 700ms is more close to desired 1000ms than +1s delay)
               So we force 1s delay in such cases. */
        } else {
            pattern_duration = 8;
            pattern_dim_time = get_light_leds_dim_time(
                    offMS > onMS ? onMS : offMS);
            pattern_data_on_bit(8000.0, onMS, offMS, &pattern_data_dec);
            pattern_delay = (totalMS - 8000 < 8000 ?
                    0 : (totalMS - 8000) / 1000);
            /* The above trick is not needed here
               since it won't make much visible difference
               when offMS > 3 * onMS here. */
        }
    }
    /* Render without timings */
    else {
        pattern_data_dec = 0;
    }

    /* Write the pattern data and clear lights */
    snprintf(pattern_data, 11, "0x%X", pattern_data_dec);
    clear_lights_locked();

#ifdef LOG_PARAM
    ALOGD("set_light_leds_locked About to write: _data=%s, _usesoftdim=%d,"
            " _duration=%d, _delay=%d, _dimtime=%d\n",
            pattern_data, pattern_use_softdim,
            pattern_duration, pattern_delay, pattern_dim_time);
#endif

    /* Using LED soft dimming */
    if (pattern_use_softdim) {
        write_string(PATTERN_DATA_FILE, pattern_data);
        write_int(PATTERN_USE_SOFTDIM_FILE, pattern_use_softdim);
        write_int(PATTERN_DURATION_SECS_FILE, pattern_duration);
        write_int(PATTERN_DELAY_FILE, pattern_delay);
        write_int(DIM_TIME_FILE, pattern_dim_time);
        write_int(PWR_RED_BRIGHTNESS_FILE, red);
        write_int(PWR_RED_USE_PATTERN_FILE, 1);
        write_int(PWR_GREEN_BRIGHTNESS_FILE, green);
        write_int(PWR_GREEN_USE_PATTERN_FILE, 1);
        write_int(PWR_BLUE_BRIGHTNESS_FILE, blue);
        write_int(PWR_BLUE_USE_PATTERN_FILE, 1);
#ifdef DEVICE_HAYABUSA
        /* This 255 may be something like last_screen_brightness==0?255:l_s_b
           But since everything is working as expected
           (LED won't be triggered when screen is on,
           including new notif arriving in lockscreen)
           It's likely that I'll never visit this again... */
        write_int(LOGO_BACKLIGHT_FILE, 255);
        write_int(LOGO_BACKLIGHT2_FILE, 255);
        write_int(LOGO_BACKLIGHT_PATTERN_FILE, 1);
        write_int(LOGO_BACKLIGHT2_PATTERN_FILE, 1);
#endif
    }
    /* Using LED direct control */
    else {
        write_int(PWR_RED_BRIGHTNESS_FILE, red);
        write_int(PWR_GREEN_BRIGHTNESS_FILE, green);
        write_int(PWR_BLUE_BRIGHTNESS_FILE, blue);
    }

    (void)dev;
    return 0;
}

/* === Module handle_leds_battery_locked === */
static void
handle_leds_battery_locked(struct light_device_t* dev) {

    /* LEDs notification mode */
    if (is_lit(&g_notification)) {
        set_light_leds_locked(dev, &g_notification);
    }
    else if (is_lit(&g_battery)) {
        set_light_leds_locked(dev, &g_battery);
    }
    else {
        clear_lights_locked();
    }
}

/* === Module set_light_leds_notifications === */
static int
set_light_leds_notifications(struct light_device_t* dev,
        struct light_state_t const* state) {

    /* LEDs notification event */
    pthread_mutex_lock(&g_lock);
    g_notification = *state;
    handle_leds_battery_locked(dev);
    pthread_mutex_unlock(&g_lock);
    return 0;
}

/* === Module set_light_leds_battery === */
static int
set_light_leds_battery(struct light_device_t* dev,
        struct light_state_t const* state) {

    /* LEDs battery event */
    pthread_mutex_lock(&g_lock);
    g_battery = *state;
    handle_leds_battery_locked(dev);
    pthread_mutex_unlock(&g_lock);
    return 0;
}

/* === Module close_lights === */
static int
close_lights(struct light_device_t *dev) {

    /* Module cleaning */
    if (dev) {
        free(dev);
    }
    return 0;
}

/* === Module open_lights === */
static int
open_lights(const struct hw_module_t* module, char const* name,
        struct hw_device_t** device) {

    /* Adaptive set_light function */
    int (*set_light)(struct light_device_t* dev,
            struct light_state_t const* state);

    /* Lights mode detection */
    if (0 == strcmp(LIGHT_ID_BACKLIGHT, name))
        set_light = set_light_lcd_backlight;
    else if (0 == strcmp(LIGHT_ID_BATTERY, name))
        set_light = set_light_leds_battery;
    else if (0 == strcmp(LIGHT_ID_NOTIFICATIONS, name))
        set_light = set_light_leds_notifications;
    else
        return -EINVAL;

    /* Module & structure initialization */
    pthread_once(&g_init, init_globals);
    struct light_device_t* dev = (struct light_device_t*) malloc(sizeof(
            struct light_device_t));
    memset(dev, 0, sizeof(*dev));

    /* Device configuration */
    dev->common.tag = HARDWARE_DEVICE_TAG;
    dev->common.version = LIGHTS_DEVICE_API_VERSION_1_0;
    dev->common.module = (struct hw_module_t*)module;
    dev->common.close = (int (*)(struct hw_device_t*))close_lights;
    dev->set_light = set_light;

    /* Device assignation */
    *device = (struct hw_device_t*)dev;
    return 0;
}

/* === Module Methods === */
static struct hw_module_methods_t lights_module_methods = {
    .open =  open_lights,
};

/* === Module Informations === */
struct hw_module_t HAL_MODULE_INFO_SYM = {
    .tag = HARDWARE_MODULE_TAG,
    .version_major = 1,
    .version_minor = 0,
    .id = LIGHTS_HARDWARE_MODULE_ID,
    .name = "Blue Lights Module",
    .author = "Google, Hamster Tian, Adrian DC",
    .methods = &lights_module_methods,
    .dso = NULL,
    .reserved = {0},
};
