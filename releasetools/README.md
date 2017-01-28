Copyright 2016 - The CyanogenMod Project  
Copyright 2017 - The LineageOS Project  

# UserData Unification Tools

These scripts are shared to build the Unified UserData migration tools.

- unify_userdata: Main unification script, includes resize_userdata
- resize_userdata: Minor automated update script to correct data partition size
- restore_sdcard: Unification reverser script to restore the original partitions


# How to build

Run the individual scripts after a full build has run.  
First parameter can be specified to select the device, default is mint.
