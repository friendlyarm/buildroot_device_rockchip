#!/bin/bash
set -eu
ROOTFS_DIR=$1

services+=("50launcher")

(cd ${ROOTFS_DIR} && {
    cd etc/init.d
    for (( i=0; i<${#services[@]}; i++ ));
    do
        [ -d S${services[$i]} ] && mv S${services[$i]} K${services[$i]}
    done
})
