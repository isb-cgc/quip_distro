#!/bin/bash
# This is script is called after the initial reboot of a camic-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

set -x

PROGNAME=$(basename "$0")

if [ "$#" -ne 4 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <admin email> <ip addr> <server alias>"
    exit 1;
fi

cd /home/cvproc/quip_distro

./run_viewer.sh $1 $2 $3 $4
