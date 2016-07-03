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


//#define LOG_NDEBUG 0
//#define LOG_PARAM
//#define LOG_BRIGHTNESS
#define LOG_TAG "Sony Lights HAL Opensource"

#include <cutils/log.h>

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
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

#include "sony_lights.h"

#ifndef CUSTOM_AS3676_SYSFS_PATH
char const*const PWR_RED_USE_PATTERN_FILE = "/sys/class/leds/pwr-red/use_pattern";
char const*const PWR_GREEN_USE_PATTERN_FILE = "/sys/class/leds/pwr-green/use_pattern";
char const*const PWR_BLUE_USE_PATTERN_FILE = "/sys/class/leds/pwr-blue/use_pattern";
char const*const PWR_RED_BRIGHTNESS_FILE = "/sys/class/leds/pwr-red/brightness";
char const*const PWR_GREEN_BRIGHTNESS_FILE = "/sys/class/leds/pwr-green/brightness";
char const*const PWR_BLUE_BRIGHTNESS_FILE = "/sys/class/leds/pwr-blue/brightness";
char const*const PATTERN_DATA_FILE = "/sys/bus/i2c/devices/10-0040/pattern_data";
char const*const PATTERN_USE_SOFTDIM_FILE = "/sys/bus/i2c/devices/10-0040/pattern_use_softdim";
char const*const PATTERN_DURATION_SECS_FILE = "/sys/bus/i2c/devices/10-0040/pattern_duration_secs";
char const*const PATTERN_DELAY_FILE = "/sys/bus/i2c/devices/10-0040/pattern_delay";
char const*const DIM_TIME_FILE = "/sys/bus/i2c/devices/10-0040/dim_time";
#endif

/******************************************************************************/

static pthread_once_t g_init = PTHREAD_ONCE_INIT;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;
static struct light_state_t g_notification;
static struct light_state_t g_battery;
static int g_attention = 0;
#ifdef DEVICE_HAYABUSA
// For sole use of controlling Xperia logo
// Thus I added tricks to this variable
// DUANG! if you use it elsewhere
int last_screen_brightness = 0;
#endif

/**
 * device methods
 */

void init_globals(void)
{
    // init the mutex
    pthread_mutex_init(&g_lock, NULL);
}

static int
write_int(char const* path, int value)
{
    int fd;
    static int already_warned = 0;

    fd = open(path, O_RDWR);
    if (fd >= 0) {
        char buffer[20];
        int bytes = sprintf(buffer, "%d\n", value);
        int amt = write(fd, buffer, bytes);
        close(fd);
        return amt == -1 ? -errno : 0;
    } else {
        if (already_warned == 0) {
            ALOGE("write_int failed to open %s\n", path);
            already_warned = 1;
        }
        return -errno;
    }
}

static int
write_string (const char *path, const char *value) {
    int fd;
    static int already_warned = 0;

    fd = open(path, O_RDWR);
    if (fd < 0) {
        if (already_warned == 0) {
            ALOGE("write_string failed to open %s\n", path);
                already_warned = 1;
        }
        return -errno;
    }

    char buffer[20];
    int bytes = snprintf(buffer, sizeof(buffer), "%s\n", value);
    int written = write (fd, buffer, bytes);
    close(fd);

    return written == -1 ? -errno : 0;
}

static int
is_lit(struct light_state_t const* state)
{
    return state->color & 0x00ffffff;
}

static int
rgb_to_brightness(struct light_state_t const* state)
{
    int color = state->color & 0x00ffffff;
    return ((77*((color>>16)&0x00ff))
            + (150*((color>>8)&0x00ff)) + (29*(color&0x00ff))) >> 8;
}

#ifdef ENABLE_GAMMA_CORRECTION
static int
brightness_apply_gamma (int brightness) {
    double floatbrt = (double) brightness;
    floatbrt /= 255.0;
#ifdef LOG_BRIGHTNESS
    ALOGV("%s: brightness = %d, floatbrt = %f", __FUNCTION__, brightness, floatbrt);
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

static int
get_max_brightness() {
    char value[6];
    int fd, len, max_brightness;

    if ((fd = open(MAX_BRIGHTNESS_FILE, O_RDONLY)) < 0) {
        ALOGE("[%s]: Could not open max brightness file %s: %s", __FUNCTION__,
                     MAX_BRIGHTNESS_FILE, strerror(errno));
        ALOGE("[%s]: Assume max brightness 255", __FUNCTION__);
        return 255;
    }

    if ((len = read(fd, value, sizeof(value))) <= 1) {
        ALOGE("[%s]: Could not read max brightness file %s: %s", __FUNCTION__,
                     MAX_BRIGHTNESS_FILE, strerror(errno));
        ALOGE("[%s]: Assume max brightness 255", __FUNCTION__);
        close(fd);
        return 255;
    }

    max_brightness = strtol(value, NULL, 10);
    close(fd);

    return (unsigned int) max_brightness;
}

static int
set_light_backlight(struct light_device_t* dev,
        struct light_state_t const* state)
{
    int err = 0;
    int brightness = rgb_to_brightness(state);
    int max_brightness = get_max_brightness();

    if (brightness > 0) {
#ifdef ENABLE_GAMMA_CORRECTION
        brightness = brightness_apply_gamma(brightness);
#endif
        brightness = max_brightness * brightness / 255;
        if (brightness < LCD_BRIGHTNESS_MIN)
            brightness = LCD_BRIGHTNESS_MIN;
    }

#ifdef LOG_BRIGHTNESS
    ALOGV("[%s] brightness %d max_brightness %d", __FUNCTION__, brightness, max_brightness);
#endif

    pthread_mutex_lock(&g_lock);
    err |= write_int (LCD_BACKLIGHT_FILE, brightness);
    err |= write_int (LCD_BACKLIGHT2_FILE, brightness);
#ifdef DEVICE_HAYABUSA
    if (brightness == 0 && is_lit(&g_notification)) {
        // Applies when turning off screen in lockscreen while there's notif
        // We don't want to write 0 (which will stop the logo from blinking)
        // Pattern file is taken care of in set_speaker_light_locked
        // Only brightness is needed here
        write_int(LOGO_BACKLIGHT_FILE, max_brightness);
        write_int(LOGO_BACKLIGHT2_FILE, max_brightness);
    } else {
        write_int(LOGO_BACKLIGHT_FILE, brightness);
        write_int(LOGO_BACKLIGHT2_FILE, brightness);
    }

    last_screen_brightness = brightness;
#endif
    pthread_mutex_unlock(&g_lock);

    return err;
}

static void
clear_lights_locked()
{
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

static int
get_dim_time(int offMS)
{
    if (offMS > 500) return 500;
    else if (offMS > 190) return 190;
    else if (offMS > 95) return 95;
    else if (offMS > 50) return 50;
    else return 50;
}

static void
pattern_data_on_bit(double duration, int onMS, int offMS, int *data)
{
    int cycle = (int)(duration / (onMS + offMS) + 0.5);
    if (cycle == 0) cycle = 1;

    int now_cycle = 0;
    int s = 0;
    int bit = 0;

    for (bit = 0; bit < 32; ++bit) {
        for (now_cycle = 0; now_cycle < cycle; ++now_cycle) {
            s = duration / 32 * bit - now_cycle * (onMS + offMS);
            if (s >= 0 && s < onMS)
                *data |= 1 << bit;
        }
    }
}

static int
set_speaker_light_locked(struct light_device_t* dev,
        struct light_state_t const* state)
{
    int alpha, red, green, blue;
    int onMS, offMS;
    unsigned int colorRGB;
    int pattern_duration = 1, pattern_dim_time = 50, pattern_data_dec = 0,
            pattern_delay = 0, pattern_use_softdim = 0;

    char pattern_data[11];

    switch (state->flashMode) {
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

    colorRGB = state->color;

#ifdef LOG_PARAM
    ALOGD("set_speaker_light_locked mode %d, colorRGB=%08X, onMS=%d, offMS=%d\n",
            state->flashMode, colorRGB, onMS, offMS);
#endif

    red = (colorRGB >> 16) & 0xFF;
    green = (colorRGB >> 8) & 0xFF;
    blue = colorRGB & 0xFF;

    if (onMS > 0 && offMS > 0) {
        if (onMS + offMS > 15000) {
            if (onMS > 8000) onMS = 8000;
            if (offMS > 15000 - onMS) offMS = 15000 - onMS;
        }

        int totalMS = onMS + offMS;

        if (totalMS < 8000 && onMS <= 1000) {
            pattern_duration = 1;
            pattern_dim_time = get_dim_time(offMS > onMS ? onMS : offMS);
            pattern_data_on_bit(1000.0, onMS, offMS, &pattern_data_dec);
            pattern_delay = totalMS - 1000 < 1000 ?
                (offMS > 3 * onMS ? 1 : 0) :
                (totalMS - 1000) / 1000;
            // When offMS is 3 times longer than onMS (eg on 300ms, off 1000ms)
            // if we only use pattern_data to describe off time (700ms)
            // it will appear too short.
            // (although 700ms is more close to desired 1000ms than +1s delay)
            // So we force 1s delay in such cases.
        } else {
            pattern_duration = 8;
            pattern_dim_time = get_dim_time(offMS > onMS ? onMS : offMS);
            pattern_data_on_bit(8000.0, onMS, offMS, &pattern_data_dec);
            pattern_delay = totalMS - 8000 < 8000 ? 0 : (totalMS - 8000) / 1000;
            // The above trick is not needed here
            // since it won't make much visible difference
            // when offMS > 3 * onMS here.
        }
    } else {
        pattern_data_dec = 0;
    }

    snprintf(pattern_data, 11, "0x%X", pattern_data_dec);

    clear_lights_locked();

#ifdef LOG_PARAM
    ALOGD("set_speaker_light_locked About to write: _data=%s, _usesoftdim=%d,"
            " _duration=%d, _delay=%d, _dimtime=%d\n",
            pattern_data, pattern_use_softdim,
            pattern_duration, pattern_delay, pattern_dim_time);
#endif

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
        // This 255 may be something like last_screen_brightness==0?255:l_s_b
        // But since everything is working as expected
        // (LED won't be triggered when screen is on,
        // including new notif arriving in lockscreen)
        // It's likely that I'll never visit this again...
        write_int(LOGO_BACKLIGHT_FILE, 255);
        write_int(LOGO_BACKLIGHT2_FILE, 255);
        write_int(LOGO_BACKLIGHT_PATTERN_FILE, 1);
        write_int(LOGO_BACKLIGHT2_PATTERN_FILE, 1);
#endif
    } else {
        write_int(PWR_RED_BRIGHTNESS_FILE, red);
        write_int(PWR_GREEN_BRIGHTNESS_FILE, green);
        write_int(PWR_BLUE_BRIGHTNESS_FILE, blue);
    }

    return 0;
}

static void
handle_speaker_battery_locked(struct light_device_t* dev)
{
    if (is_lit(&g_notification))
        set_speaker_light_locked(dev, &g_notification);
    else if(is_lit(&g_battery))
        set_speaker_light_locked(dev, &g_battery);
    else
        // No light required. Clear everything.
        clear_lights_locked();
}

static int
set_light_notifications(struct light_device_t* dev,
        struct light_state_t const* state)
{
    pthread_mutex_lock(&g_lock);
    g_notification = *state;
    handle_speaker_battery_locked(dev);
    pthread_mutex_unlock(&g_lock);
    return 0;
}

static int
set_light_battery(struct light_device_t* dev,
        struct light_state_t const* state)
{
    pthread_mutex_lock(&g_lock);
    g_battery = *state;
    handle_speaker_battery_locked(dev);
    pthread_mutex_unlock(&g_lock);
    return 0;
}


/** Close the lights device */
static int
close_lights(struct light_device_t *dev)
{
    if (dev) {
        free(dev);
    }
    return 0;
}


/******************************************************************************/

/**
 * module methods
 */

/** Open a new instance of a lights device using name */
static int open_lights(const struct hw_module_t* module, char const* name,
        struct hw_device_t** device)
{
    int (*set_light)(struct light_device_t* dev,
            struct light_state_t const* state);

    // There are no attention LED or button backlight in Sony blue devices
    if (0 == strcmp(LIGHT_ID_BACKLIGHT, name))
        set_light = set_light_backlight;
    else if (0 == strcmp(LIGHT_ID_NOTIFICATIONS, name))
        set_light = set_light_notifications;
    else if (0 == strcmp(LIGHT_ID_BATTERY, name))
        set_light = set_light_battery;
    else
        return -EINVAL;

    pthread_once(&g_init, init_globals);

    struct light_device_t *dev = (light_device_t*)malloc(sizeof(struct light_device_t));
    memset(dev, 0, sizeof(*dev));

    dev->common.tag = HARDWARE_DEVICE_TAG;
    dev->common.version = 0;
    dev->common.module = (struct hw_module_t*)module;
    dev->common.close = (int (*)(struct hw_device_t*))close_lights;
    dev->set_light = set_light;

    *device = (struct hw_device_t*)dev;
    return 0;
}

static struct hw_module_methods_t lights_module_methods = {
    .open =  open_lights,
};

/*
 * The lights Module
 */
struct hw_module_t HAL_MODULE_INFO_SYM = {
    .tag = HARDWARE_MODULE_TAG,
    .version_major = 1,
    .version_minor = 0,
    .id = LIGHTS_HARDWARE_MODULE_ID,
    .name = "Sony Lights Module for AS3676",
    .author = "Google, Hamster Tian",
    .methods = &lights_module_methods,
    .dso = NULL, /* remove compilation warnings */
    .reserved = {0}, /* remove compilation warnings */
};
