#!/bin/bash

set -x

VIEWER_VERSION=0.9

### Install git
https://github.com/isb-cgc/quip_distro.git

### Install docker
#sudo apt-get -y install \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     software-properties-common

sudo apt-get install --no-install-recommends \
    apt-transport-https \
    curl \
    software-properties-common

#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -
#sudo add-apt-repository \
#     "deb [arch=amd64] https://download.docker.com/linux/debian \
#     $(lsb_release -cs) stable"

sudo add-apt-repository \
   "deb https://packages.docker.com/1.12/apt/repo/ \
   ubuntu-$(lsb_release -cs) \
   main"

sudo apt-get update

sudo apt-get -y install docker-engine

git clone isb-cgc-webapp https://github.com/isb-cgc/quip_distro.git

cd quip_distro

./run_viewer $VIEWER_VERSION