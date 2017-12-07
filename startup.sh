#!/bin/bash
# This is script is called after the initial reboot of a camic-viewer VM.
# We want to execute run_viewer.sh as the same user that instantiated the VM.

cd /home/$IAM/quip_distro
su $IAM
./run_viewer.sh $1
