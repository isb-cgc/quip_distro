#!/bin/bash

set -x

VIEWER_VERSION=0.9
#SERVER_ADMIN=$1
#SERVER_NAME=$2
#SERVER_ALIAS=$3
#CONFIG_BUCKET=$4
#WEBAPP=$5
BRANCH=$1
MACHINE_URL=$2
CONFIG_BUCKET=$3
WEBAPP=$4

### Trying the following to avoid spurious "Could not get lock /var/lib/dpkg/lock"
### errors that are sometimes seen with the following installs
#sleep 10

### See if anything is still holding lock on /var/lib/dpkg/lock                                                                
function wait_on_lock()
{
    PID=$(sudo lsof -F p  /var/lib/dpkg/lock | grep p | sed 's/p//')
    while [ -n "$PID" ]
    do
        echo "Waiting on held lock"
        ps -f -p $PID
        sleep 5
        PID=$(sudo lsof -F p  /var/lib/dpkg/lock | grep p | sed 's/p//')
    done
}

wait_on_lock
### Install git
sudo apt-get -y install git

### The startup script is in the quip_distro repo
git clone -b $BRANCH https://github.com/isb-cgc/quip_distro.git
cd quip_distro

wait_on_lock
./build/install_docker.sh
### Install docker
#sudo apt-get -y install --no-install-recommends \
#    apt-transport-https \
#    curl \
#    software-properties-common
#curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -
#sudo add-apt-repository \
#   "deb https://packages.docker.com/1.12/apt/repo/ \
#   ubuntu-$(lsb_release -cs) \
#   main"
#sudo apt-get update
#sudo apt-get -y install docker-engine

### Get https certificates
#sudo mkdir -p /etc/apache2/ssl
#sudo gsutil cp gs://$CONFIG_BUCKET/ssl/camic-viewer-apache.crt /etc/apache2/ssl
#sudo gsutil cp gs://$CONFIG_BUCKET/ssl/camic-viewer-apache.key /etc/apache2/ssl

### Automatically run a script on rebooting
# sudo sed -i '/By default/a \'$HOME'/quip_distro/run_viewer.sh '$VIEWER_VERSION' || exit 1' /etc/rc.local 
#sudo sed -i '/By default/a \'$HOME'/quip_distro/startup.sh '$VIEWER_VERSION' '$SERVER_ADMIN' '$SERVER_NAME' '$SERVER_ALIAS' '$WEBAPP' || exit 1' /etc/rc.local 
sudo sed -i '/By default/a \'$HOME'/quip_distro/startup.sh '$VIEWER_VERSION' '$BRANCH' '$WEBAPP' || exit 1' /etc/rc.local

### Install nginx and certbot
./build/install_nginx.sh $CONFIG_BUCKET $MACHINE_URL

### Install and run Tenable
# Get Tenable the key from GCS                                                                                  
sudo gsutil cp gs://$CONFIG_BUCKET/tenable_key.txt tenable_key.txt
KEY=$(<tenable_key.txt)
sudo rm tenable_key.txt
# Install package (package previously downloaded from tenable.io)
sudo gsutil cp  gs://isb-cgc-misc/compute-helpers/NessusAgent-7.0.2-debian6_amd64.deb /tmp
sudo  dpkg -i /tmp/NessusAgent-7.0.2-debian6_amd64.deb
# Link agent (key obtained from tenable.io web app)
sudo /opt/nessus_agent/sbin/nessuscli agent link --key=$KEY --cloud
# Start agent
sudo /etc/init.d/nessusagent start

###Install clamav
sudo apt install -y clamav clamav-daemon
wget https://raw.githubusercontent.com/isb-cgc/ISB-CGC-Cron/master/gce_vm_tasks/virus_scan.sh?token=AIDOy_cOcMmcva217njQkMtrB3alVbrRks5ay64awA%3D%3D -O virus_scan
chmod 0755 virus_scan
sudo cp virus_scan /etc/cron.daily/
sudo sed -ie 's/Checks 24/Checks 2/' /etc/clamav/freshclam.conf

### Do the update/upgrade thing
sudo apt-get -y update
sudo apt-get -y upgrade

### Reboot so that update/upgrade takes effect
sudo reboot
