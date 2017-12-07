#!/bin/bash
# This is script is called after the initial reboot of a camic-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

cd /home/cvproc/quip_distro

sudo --user cvproc ./run_viewer.sh $1
