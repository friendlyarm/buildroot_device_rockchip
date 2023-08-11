#!/bin/bash
set -eu
ROOTFS_DIR=$(readlink -f $1)
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}
pushd ../../
export SDK_DIR=$PWD
export RK_TOOL_DIR=$PWD/device/rockchip/common/tools
export RK_SESSION=1
export FRIENDLYELEC_SESSION=1
export RK_OUTDIR=/tmp/rk_outdir
mkdir -p ${RK_OUTDIR}
source $SDK_DIR/.current_config.mk
export RK_KERNEL_CFG=${TARGET_KERNEL_CONFIG}
cd kernel
export RK_KERNEL_VERSION=$(make kernelrelease)
popd
# -------------------------

####
# apply rockchip post-hooks scripts
./common/fonts/install.sh $ROOTFS_DIR
./common/tools/install.sh $ROOTFS_DIR
pushd common/post-hooks
./05-udev.sh $ROOTFS_DIR
./06-async-commit.sh $ROOTFS_DIR
./10-os-release.sh $ROOTFS_DIR
sed -i "s/^BUILD_INFO=.*/BUILD_INFO=\"bot@friendlyelec $(date +%Y-%m-%d)\"/" $ROOTFS_DIR/etc/os-release
./30-fstab.sh $ROOTFS_DIR && sed -i '/\/dev\/root/d' $ROOTFS_DIR/etc/fstab
./40-busybox-reboot.sh $ROOTFS_DIR
./50-locale.sh $ROOTFS_DIR
./60-dirs.sh $ROOTFS_DIR
./90-overlay.sh $ROOTFS_DIR
./99-owner.sh $ROOTFS_DIR
popd

####
# oem
pushd ${SDK_DIR}
[ -d ${ROOTFS_DIR}/oem ] || mkdir ${ROOTFS_DIR}/oem
cp -af ${SDK_DIR}/device/rockchip/common/images/oem/oem_normal/* ${ROOTFS_DIR}/oem
# userdata
[ -d ${ROOTFS_DIR}/userdata ] || mkdir ${ROOTFS_DIR}/userdata
cp -af ${SDK_DIR}/device/rockchip/common/images/userdata/userdata_normal/* ${ROOTFS_DIR}/userdata
popd

# clean
unset SDK_DIR RK_SESSION RK_TOOL_DIR FRIENDLYELEC_SESSION RK_KERNEL_VERSION RK_KERNEL_CFG RK_OUTDIR
