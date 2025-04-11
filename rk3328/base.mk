#!/bin/bash

TARGET_PLAT=rk3328
TARGET_ARCH=arm64
CROSS_COMPILER=aarch64-linux-gnu-
TARGET_OSNAME=buildroot

# buildroot
# 

TARGET_BUILDROOT_CONFIG=friendlyelec_rk3328_defconfig
BUILDROOT_SRC=buildroot
BUILDROOT_FILES+=(device/friendlyelec/overwrite-rk-files)
BUILDROOT_FILES+=(device/friendlyelec/keep-the-net-classic-naming)
BUILDROOT_FILES+=(device/friendlyelec/network-interfaces)
BUILDROOT_FILES+=(device/friendlyelec/network-leds)
BUILDROOT_FILES+=(device/friendlyelec/fancontrol)
BUILDROOT_FILES+=(device/friendlyelec/rom-version)
BUILDROOT_FILES+=(device/friendlyelec/disable-unnecessary-services)
BUILDROOT_FILES+=(device/friendlyelec/rk3328/disable-gui)
BUILDROOT_FILES+=(device/friendlyelec/rk3328/rtl8822c-conf)
BUILDROOT_FILES+=(device/friendlyelec/load-modules-service)
BUILDROOT_FILES+=(device/friendlyelec/usbdevice-wrapper)

# U-boot
# 

TARGET_UBOOT_CONFIG=nanopi_r2_defconfig

# Kernel
# 

TARGET_KERNEL_CONFIG=nanopi4_linux_defconfig
TARGET_KERNEL_DTB=resource.img

# Misc
# 
TARGET_IMAGE_DIRNAME=buildroot
TARGET_SD_RAW_FILENAME=Buildroot_$(date +%Y%m%d)_RK3328_arm64_sd.img
TARGET_EFLASHER_RAW_FILENAME=Buildroot_$(date +%Y%m%d)_RK3328_arm64_eflasher.img


