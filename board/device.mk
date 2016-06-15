# Device vendor
BOARD_VENDOR := sony
BOARD_VENDOR_PLATFORM := blue

# Use legacy MMAP for pre-lollipop blobs
BOARD_USES_LEGACY_MMAP := true

# Dumpstate
BOARD_LIB_DUMPSTATE := libdumpstate.sony

# Bionic
MALLOC_IMPL := dlmalloc

# Release tools
TARGET_RELEASETOOLS_EXTENSIONS := $(COMMON_PATH)/releasetools
