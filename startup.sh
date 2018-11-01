#!/bin/bash
# This is script is called after the initial reboot of a camic-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

# $1=VIEWER_VERSION
# $2=WEBAPP
# $3=PROJECT
set -x

PROGNAME=$(basename "$0")

if [ "$#" -ne 3 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <webapp>"
    exit 1;
fi

cd /home/cvproc/quip_distro

sudo rm log.txt
./run_viewer.sh $1 $2 $3 &> log.txt
