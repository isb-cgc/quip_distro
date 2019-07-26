#!/bin/bash

set -x

#VERSION=1.0
VIEWER_VERSION=$1
WEBAPP=$2
PROJECT=$3

PROGNAME=$(basename "$0")

if [ "$#" -ne 3 ]; then
    echo "Usage: ./$PROGNAME <quip-viewer version> <webapp>"
    exit 1;
fi

echo "Removing existing containers"
sudo docker rm -f quip-viewer

echo "Starting Containers..."

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

### Get the previously created viewer container from GCR 
PATH=/usr/lib/google-cloud-sdk/bin:`echo $PATH`
echo $PATH
### Extending the path above should be sufficient, but seem to need to create the following link
DCG=$(sudo find /snap -name docker-credential-gcloud | grep -m 1 docker-credential-gcloud)
sudo rm /usr/bin/docker-credential-gcloud
sudo ln -s $DCG /usr/bin/docker-credential-gcloud
sudo gcloud auth configure-docker --quiet
sudo docker pull gcr.io/$PROJECT/quip_viewer:$VIEWER_VERSION
if [[ $? == 1 ]]; then
    echo "Pulling from GCR failed. Build it instead"
    if [[ "$(docker images -q quip-viewer:$VIEWER_VERSION 2> /dev/null)" == "" ]]; then
        git clone -b $BRANCH https://github.com/isb-cgc/ViewerDockerContainer.git ./ViewerDockerContainer
        sudo docker build -t quip_viewer:$VIEWER_VERSION -f ViewerDockerContainer/Dockerfile ViewerDockerContainer
    fi
fi  

## Run viewer container
viewer_container=$(sudo docker run --privileged --name=quip-viewer --net=quip_nw -itd \
    -p $VIEWER_PORT:80 \
    -e WEBAPP=$WEBAPP \
    -v /etc/apache2/ssl:/etc/apache2/ssl \
    -v $HOME/.aws:/var/www/.aws \
    gcr.io/$PROJECT/quip_viewer:$VIEWER_VERSION)
echo "Started viewer container: " $viewer_container
