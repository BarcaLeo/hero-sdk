#!/bin/bash

make ARCH=${KERNEL_ARCH} CROSS_COMPILE=${KERNEL_CROSS_COMPILE} -j${N_CORES_COMPILE} modules O=out/juno-oe
make ARCH=${KERNEL_ARCH} CROSS_COMPILE=${KERNEL_CROSS_COMPILE} modules_install INSTALL_MOD_PATH=lib_modules O=out/juno-oe
