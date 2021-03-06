#
# Creates the init.sh script used to toggle between regular and recovery boots
# on the shinano and aries devices.
#

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.sh
LOCAL_MODULE_PATH  := $(TARGET_ROOT_OUT)/sbin
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES    := init.sh
LOCAL_REQUIRED_MODULES := static_min_busybox init extract_elf_ramdisk
include $(BUILD_PREBUILT)

root_init      := $(TARGET_ROOT_OUT)/init
root_init_real := $(TARGET_ROOT_OUT)/init.real

	# If /init is a file and not a symlink then rename it to /init.real
	# and make /init be a symlink to /sbin/init.sh (which will execute
	# /init.real, if appropriate.
$(root_init_real): $(root_init) $(TARGET_ROOT_OUT)/sbin/bootrec-device $(PRODUCT_OUT)/utilities/busyboxmin
	cp $(PRODUCT_OUT)/utilities/busyboxmin $(TARGET_ROOT_OUT)/sbin/busybox
	$(hide) if [ ! -L $(root_init) ]; then \
	  echo "/init $(root_init) isn't a symlink"; \
	  mv $(root_init) $(root_init_real); \
	  ln -s sbin/init.sh $(root_init); \
	else \
	  echo "/init $(root_init) is already a symlink"; \
	fi
	$(hide) rm -f $(TARGET_ROOT_OUT)/sbin/sh
	$(hide) ln -s busybox $(TARGET_ROOT_OUT)/sbin/sh

ALL_DEFAULT_INSTALLED_MODULES += $(root_init_real)

include $(CLEAR_VARS)
LOCAL_MODULE       := extract_elf_ramdisk
LOCAL_MODULE_PATH  := $(TARGET_ROOT_OUT)/sbin
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS  := optional
LOCAL_SRC_FILES    := extract_elf_ramdisk.c
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_PACK_MODULE_RELOCATIONS := false
LOCAL_STATIC_LIBRARIES := libelf libc libm libz
LOCAL_C_INCLUDES := \
	external/elfutils/src/libelf \
	external/zlib
LOCAL_CFLAGS := -g -c -W
include $(BUILD_EXECUTABLE)

