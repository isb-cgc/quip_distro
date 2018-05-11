#!/bin/bash

set -x

VIEWER_VERSION=0.9
SERVER_ADMIN=$1
SERVER_NAME=$2
SERVER_ALIAS=$3
SSL_BUCKET=$4
WEBAPP=$5

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

### Get https certificates
sudo mkdir -p /etc/apache2/ssl
sudo gsutil cp gs://$SSL_BUCKET/ssl/camic-viewer-apache.crt /etc/apache2/ssl
sudo gsutil cp gs://$SSL_BUCKET/ssl/camic-viewer-apache.key /etc/apache2/ssl

### Automatically run a script on rebootingr
# sudo sed -i '/By default/a \'$HOME'/quip_distro/run_viewer.sh '$VIEWER_VERSION' || exit 1' /etc/rc.local 
sudo sed -i '/By default/a \'$HOME'/quip_distro/startup.sh '$VIEWER_VERSION' '$SERVER_ADMIN' '$SERVER_NAME' '$SERVER_ALIAS' '$WEBAPP' || exit 1' /etc/rc.local 
### The startup script is in the quip_distro repo
git clone -b isb-cgc-webapp https://github.com/isb-cgc/quip_distro.git

# Install package (package previously downloaded from tenable.io)
sudo gsutil cp  gs://isb-cgc-misc/compute-helpers/NessusAgent-7.0.2-debian6_amd64.deb /tmp
sudo  dpkg -i /tmp/NessusAgent-7.0.2-debian6_amd64.deb
# Link agent (key obtained from tenable.io web app)
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=***REMOVED*** --cloud
# Start agent
sudo /etc/init.d/nessusagent start

#Install clamav
sudo apt install -y clamav clamav-daemon
#wget https://raw.githubusercontent.com/isb-cgc/ISB-CGC-Cron/master/gce_vm_tasks/virus_scan.sh?token=AKBQyIdXio073v7hMOxWHnXCCpDqxgl7ks5alcxdwA%3D%3D -O virus_scan
wget https://raw.githubusercontent.com/isb-cgc/ISB-CGC-Cron/master/gce_vm_tasks/virus_scan.sh?token=AIDOy_cOcMmcva217njQkMtrB3alVbrRks5ay64awA%3D%3D -O virus_scan
chmod 0755 virus_scan
sudo cp virus_scan /etc/cron.daily/
sudo sed -ie 's/Checks 24/Checks 2/' /etc/clamav/freshclam.conf

### Do the update/upgrade thing
sudo apt-get -y update
sudo apt-get -y upgrade

### Reboot so that update/upgrade takes effect
sudo reboot
