#!/bin/bash

set -x

VIEWER_VERSION=0.9

### Install git
sudo apt-get -y install git

sudo apt-get -y install --no-install-recommends \
    apt-transport-https \
    curl \
    software-properties-common

curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -
sudo add-apt-repository \
   "deb https://packages.docker.com/1.12/apt/repo/ \
   ubuntu-$(lsb_release -cs) \
   main"

sudo apt-get update
sudo apt-get -y install docker-engine

### The quip_distro repo has scripts that we'll run after reboot
git clone -b isb-cgc-webapp https://github.com/isb-cgc/quip_distro.git

### Automatically run a startup script after
# sudo sed -i '/By default/a \'$HOME'/quip_distro/run_viewer.sh '$VIEWER_VERSION' || exit 1' /etc/rc.local 
sudo sed -i '/By default/a \'$HOME'/quip_distro/startup.sh '$VIEWER_VERSION' || exit 1' /etc/rc.local 

sudo apt-get -y update
sudo apt-get -y upgrade

sudo reboot
