#!/bin/bash
set -eu
ROOTFS_DIR=$1

(cd ${ROOTFS_DIR} && {
	if [ ! -d etc/sysconfig ]; then
		mkdir -p etc/sysconfig
		touch etc/sysconfig/modules
		echo "warning: not found etc/sysconfig, please check"
	fi
	echo 'bcmdhd' >> etc/sysconfig/modules
})
