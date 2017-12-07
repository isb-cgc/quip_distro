#!/bin/bash

set -x

VIEWER_VERSION=0.9

### Trying the following to avoid spurious "Could not get lock /var/lib/dpkg/lock"
### errors that are sometimes seen with the following installs
sleep 10

### Install git
sudo apt-get -y install git

### Install docker
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

### Automatically run a startup script after
# sudo sed -i '/By default/a \'$HOME'/quip_distro/run_viewer.sh '$VIEWER_VERSION' || exit 1' /etc/rc.local 
sudo sed -i '/By default/a \'$HOME'/quip_distro/startup.sh '$VIEWER_VERSION' || exit 1' /etc/rc.local 
### The scripts are in the quip_distro
git clone -b isb-cgc-webapp https://github.com/isb-cgc/quip_distro.git

# Install Tenable package (package previously downloaded from tenable.io)
gsutil cp  gs://isb-cgc-misc/NessusAgent-6.11.2-ubuntu1110_amd64.deb /tmp
sudo  dpkg -i /tmp/NessusAgent-6.11.2-ubuntu1110_amd64.deb
# Link agent (key obtained from tenable.io web app)
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=6d6af5bd230501cf2f8138542349f8437ca3476b00dd3a59877ca1524e467e6e --cloud
# Start agent
sudo /etc/init.d/nessusagent start

### Do the update/upgrade thing
sudo apt-get -y update
sudo apt-get -y upgrade

### Reboot so that update/upgrade takes effect
sudo reboot
