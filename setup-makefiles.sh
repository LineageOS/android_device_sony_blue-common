#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
#           (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Abort if device not inherited
if  [ -z "$DEVICE" ]; then
    echo "Variable DEVICE not defined, aborting..."
    exit 1
fi

# Required!
export DEVICE_COMMON=blue-common
export DEVICE_NAME=$DEVICE
export VENDOR=sony

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

ROM_ROOT="$MY_DIR"/../../..

HELPER="$ROM_ROOT"/vendor/cm/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

# Initialize the helper for common device
DEVICE=$DEVICE_COMMON
setup_vendor "$DEVICE" "$VENDOR" "$ROM_ROOT" true

# Copyright headers and common guards
write_headers "hayabusa mint tsubasa"

# Sony/Board specific blobs
write_makefiles "$MY_DIR"/proprietary-files-sony.txt
printf '\n' >> "$PRODUCTMK"

# QCom common board blobs
write_makefiles "$MY_DIR"/proprietary-files-qc.txt

write_footers

# Reinitialize the helper for device
DEVICE=$DEVICE_NAME
setup_vendor "$DEVICE" "$VENDOR" "$ROM_ROOT"

# Copyright headers and guards
write_headers

# Sony/Device specific blobs
write_makefiles "$MY_DIR"/../$DEVICE/proprietary-files-sony.txt
printf '\n' >> "$PRODUCTMK"

# QCom common device blobs
write_makefiles "$MY_DIR"/../$DEVICE/proprietary-files-qc.txt

# Vendor BoardConfig variables
printf 'USE_CAMERA_STUB := false\n' >> "$BOARDMK"

write_footers
