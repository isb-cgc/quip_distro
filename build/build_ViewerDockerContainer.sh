#!/bin/bash                                                                                                                     

set -x

BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
VIEWER_VERSION=0.91

git clone -b $BRANCH https://github.com/isb-cgc/ViewerDockerContainer.git ./ViewerDockerContainer
docker build -t quip_viewer:$VIEWER_VERSION -f ViewerDockerContainer/Dockerfile ViewerDockerContainer

docker tag quip_viewer gcs.io/isb-cgc/quip_viewer:$VIEWER_VERION
docker push gcs.io/isb-cgc/quip_viewer:$VIEWER_VERION
docker tag quip_viewer gcs.io/isb-cgc-test/quip_viewer:$VIEWER_VERION
docker push gcs.io/isb-cgc-test/quip_viewer:$VIEWER_VERION
docker tag quip_viewer gcs.io/isb-cgc-uat/quip_viewer:$VIEWER_VERION
docker push gcs.io/isb-cgc-uat/quip_viewer:$VIEWER_VERION

rm -r ViewerDockerContainer
