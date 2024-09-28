#!/bin/bash
set -eu
ROOTFS_DIR=$(readlink -f $1)
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}
log_info() {
    local now=`date +%s`
    printf "\033[1;32m[INFO]: $* \033[0m \n"
}
pushd ../../
export SDK_DIR=$PWD
export SCRIPTS_DIR=$PWD/device/rockchip/common/scripts
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

## {{
pushd common/post-hooks
declare -a hookscripts=()
#disable# hookscripts+=("00-wifibt.sh")
#disable# hookscripts+=("01-hostname.sh")
hookscripts+=("02-usb.sh")
hookscripts+=("05-udev.sh")
hookscripts+=("06-async-commit.sh")
#disable# hookscripts+=("09-disk.sh")
hookscripts+=("10-os-release.sh")
#disable# hookscripts+=("20-info.sh")
hookscripts+=("30-fstab.sh")
hookscripts+=("40-busybox-reboot.sh")
hookscripts+=("50-locale.sh")
hookscripts+=("60-dirs.sh")
hookscripts+=("90-overlay.sh")
#disable# hookscripts+=("95-partitions.sh")
hookscripts+=("99-owner.sh")
for (( i=0; i<${#hookscripts[@]}; i++ ));
do
    ./${hookscripts[$i]} $ROOTFS_DIR
    log_info "apply device/rockchip/common/post-hooks/${hookscripts[$i]} ret $?"
done
popd
## }}
sed -i "s/^BUILD_INFO=.*/BUILD_INFO=\"bot@friendlyelec $(date +%Y-%m-%d)\"/" $ROOTFS_DIR/etc/os-release
sed -i '/\/dev\/root/d' $ROOTFS_DIR/etc/fstab

####
# oem
pushd ${SDK_DIR}
[ -d ${ROOTFS_DIR}/oem ] || mkdir ${ROOTFS_DIR}/oem
cp -af ${SDK_DIR}/device/rockchip/common/images/oem/normal/* ${ROOTFS_DIR}/oem
# userdata
[ -d ${ROOTFS_DIR}/userdata ] || mkdir ${ROOTFS_DIR}/userdata
cp -af ${SDK_DIR}/device/rockchip/common/images/userdata/normal/* ${ROOTFS_DIR}/userdata
popd

# clean
unset SDK_DIR RK_SESSION RK_TOOL_DIR FRIENDLYELEC_SESSION RK_KERNEL_VERSION RK_KERNEL_CFG RK_OUTDIR
