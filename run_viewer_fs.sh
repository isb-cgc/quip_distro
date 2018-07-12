#!/bin/bash

set -x

# $1=VIEWER_VERSION                                                                                                                                           
# $2=SERVER_ADMIN                                                                                                                                             
# $3=SERVER_NAME                                                                                                                                              
# $4=SERVER_ALIAS                                                                                                                                            
# $5=WEBAPP                                                                                                                                                   
PROGNAME=$(basename "$0")

if [ "$#" -ne 5 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <admin email> <ip addr> <server alias> <webapp>"
    exit 1;
fi

echo "Removing existing containers"
sudo docker rm -f quip-viewer

echo "Starting Containers..."

#VERSION=1.0
VIEWER_VERSION=$1

#STORAGE_FOLDER=$PWD/data

sudo docker network create quip_nw

#IMAGES_DIR=$(echo $STORAGE_FOLDER/img)
#DATABASE_DIR=$(echo $STORAGE_FOLDER/data)

#mkdir -p $IMAGES_DIR 
#mkdir -p $DATABASE_DIR

VIEWER_PORT=5001
#IMAGELOADER_PORT=6002
#FINDAPI_PORT=3000

#data_host="http://quip-data:9099"
#mongo_host="quip-data"
#mongo_port=27017

#\cp -rf configs $STORAGE_FOLDER/.
#CONFIGS_DIR=$(echo $STORAGE_FOLDER/configs)

if [[ "$(docker images -q quip-viewer:$VIEWER_VERSION 2> /dev/null)" == "" ]]; then
  git clone -b isb-cgc-webapp https://github.com/isb-cgc/ViewerDockerContainer.git ./ViewerDockerContainer
  sudo docker build -t quip_viewer:$VIEWER_VERSION -f ViewerDockerContainer/Dockerfile ViewerDockerContainer
fi

## Run viewer container
viewer_container=$(sudo docker run --privileged --name=quip-viewer --net=quip_nw -itd \
    -p $VIEWER_PORT:443 \
    -e SERVER_ADMIN=$2 \
    -e SERVER_NAME=$3 \
    -e SERVER_ALIAS=$4 \
    -e WEBAPP=$5 \
    -v /etc/apache2/ssl:/etc/apache2/ssl \
    -v /mnt/disks/imaging-west:/data/images/imaging-west \
    quip_viewer:$VIEWER_VERSION)
echo "Started viewer container: " $viewer_container
#    -v /mnt/disks/imaging-west:/data/images/filestore \
