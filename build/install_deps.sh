#!/bin/bash

set -x

VIEWER_VERSION=0.9
BRANCH=$1
MACHINE_URL=$2
CONFIG_BUCKET=$3
WEBAPP=$4
PROJECT=$5

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
sudo apt-get update

wait_on_lock
### Install git
sudo apt-get -y install git

### The startup script is in the quip_distro repo
git clone -b $BRANCH https://github.com/isb-cgc/quip_distro.git
cd quip_distro

wait_on_lock
./build/install_docker.sh

### Automatically run a script on rebooting
#sudo sed -i '/By default/a \'$HOME'/quip_distro/startup.sh '$VIEWER_VERSION' '$WEBAPP' '$PROJECT' || exit 1' /etc/rc.local
crontab -l > mycron
echo "@reboot $HOME/quip_distro/startup.sh $VIEWER_VERSION $WEBAPP $PROJECT 2>&1 | tee $HOME/quip_distro/log.txt" >> mycron
crontab mycron
rm mycron

### Install nginx and certbot
./build/install_nginx.sh $CONFIG_BUCKET $MACHINE_URL $PROJECT

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
