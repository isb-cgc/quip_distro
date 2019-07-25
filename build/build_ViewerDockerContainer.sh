#!/bin/bash                                                                                                                     

set -x

BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
VIEWER_VERSION=0.91

git clone -b $BRANCH https://github.com/isb-cgc/ViewerDockerContainer.git ./ViewerDockerContainer
docker build -t quip_viewer:$VIEWER_VERSION -f ViewerDockerContainer/Dockerfile ViewerDockerContainer

gcloud config set project isb-cgc
docker tag quip_viewer:$VIEWER_VERSION gcr.io/isb-cgc/quip_viewer:$VIEWER_VERSION
docker push gcr.io/isb-cgc/quip_viewer:$VIEWER_VERSION

gcloud config set project isb-cgc-test
docker tag quip_viewer:$VIEWER_VERSION gcr.io/isb-cgc-test/quip_viewer:$VIEWER_VERSION
docker push gcr.io/isb-cgc-test/quip_viewer:$VIEWER_VERSION

gcloud config set project isb-cgc-uat
docker tag quip_viewer:$VIEWER_VERSION gcr.io/isb-cgc-uat/quip_viewer:$VIEWER_VERSION
docker push gcr.io/isb-cgc-uat/quip_viewer:$VIEWER_VERSION

rm -rf ViewerDockerContainer
