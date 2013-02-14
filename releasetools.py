# Copyright (C) 2012 The Android Open Source Project
# Copyright (C) 2012-2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Custom OTA Package commands for blue"""

import common
import os

LOCAL_DIR = os.path.dirname(os.path.abspath(__file__))
TARGET_DIR = os.getenv('OUT')
TARGET_DEVICE = os.getenv('CM_BUILD')

def FullOTA_Assertions(info):
  if TARGET_DEVICE == "mint":
    info.output_zip.write(os.path.join(TARGET_DIR, "lk.elf"), "lk.elf")
    info.output_zip.write(os.path.join(TARGET_DIR, "partition.sh"), "partition.sh")
    info.script.AppendExtra(
          ('package_extract_file("partition.sh", "/tmp/partition.sh");\n'
           'set_perm(0, 0, 0777, "/tmp/partition.sh");'))
    info.script.AppendExtra('package_extract_file("lk.elf", "/tmp/lk.elf");')
    info.script.AppendExtra('assert(run_program("/tmp/partition.sh") == 0);')
    info.script.AppendExtra('run_program("/sbin/dd", "if=/tmp/lk.elf", "of=/dev/block/mmcblk0p4");')

def FullOTA_InstallEnd(self):
  self.script.AppendExtra('package_extract_file("system/bin/fix_storage_permissions.sh", "/tmp/fix_storage_permissions.sh");')
  self.script.AppendExtra('set_perm(0, 0, 0777, "/tmp/fix_storage_permissions.sh");')
  self.script.AppendExtra('run_program("/tmp/fix_storage_permissions.sh");')
