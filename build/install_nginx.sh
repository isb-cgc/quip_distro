#!/bin/bash

CONFIG_BUCKET=$1
MACHINE_URL=$2

set -x

# First install nginx
sudo apt-get install -y nginx
sudo cp ./nginx/nginx.conf /etc/nginx/nginx.conf

# Now install certbot
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-nginx 

# Get the admin email address
sudo gsutil cp gs://$CONFIG_BUCKET/ir_addr.txt .
SERVER_ADMIN=`cat ir_addr.txt`
sudo rm ir_addr.txt

# We first delete any existing certs
#sudo certbot delete --non-interactive

# Then we create a new cert. Note that Let's Encrypt strictly limits creating new certs on the
# same domain to 10 in a one week period. 
sudo certbot --nginx -m $SERVER_ADMIN -d $MACHINE_URL --redirect --agree-tos --non-interactive --staging

# Edit the letsencrypt config file so as to not enable TLS v1.0
sudo sed -ie 's/TLSv1 / /' /etc/letsencrypt/options-ssl-nginx.conf

# Start nginx
sudo nginx


#CERTS=`sudo certbot certificates`

### See if we already have a valid certificate
#if [[ $CERTS == "" ]] || [[ $CERTS== *"INVALID"* ]] || [[ $CERTS != *"camic-viewer-dev.isb-cgc.org"* ]]; 
#then 
    # No cert or an invalid certificate for this subdomain exists. We assume that nginx.conf has been configured by
    # letsencrypt/certbot.
    # Delete the invalid certificate
#    sudo certbot delete
    # Get a valid certificate for this VM. It will expire in 90 days, but certbot should renew it.
#    sudo certbot --nginx -m $SERVER_ADMIN -d $MACHINE_URL --redirect --agree-tos --non-interactive
#else
    # A valid certificate for this subdomain exists. However, since this is a new VM, we need certbot to configure nginx.conf.
    # So we get an invalid certificate for this VM. This will have the side effect of fixing the nginx.conf as needed.
#    sudo certbot --nginx -m $SERVER_ADMIN -d $MACHINE_URL --redirect --agree-tos --non-interactive --staging
    # Now we can delete the invalid cert and refresh with a valid cert.
    ## sudo cerbot delete
    # Then, we tell certbot to renew the certificate. This should install a "real" cert.
#    sudo certbot renew
#fi

