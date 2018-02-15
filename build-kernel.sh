#!/bin/bash
#
# Details:
#   Author: Lars Erik Storbukås <larserik@storbukas.no>
#           http://larserik.storbukas.no
#   Date: 14/02-2018
#
# Linux Kernel Build script
# ------------------------
# This script simplifies the kernel build by executing
# the steps required to compile and install a custom
# Linux Kernel. Must be run with sudo privileges.

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

make -j4 O=/kernel/ LOCALVERSION="-da-lbe"
make -j4 O=/kernel/ modules_install install
make headers_install ARCH=x86 INSTALL_HDR_PATH=/usr
