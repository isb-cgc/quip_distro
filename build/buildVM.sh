#!/usr/bin/env bash
set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: ./$PROGNAME <external IP address>"
    exit 1;
fi


EXTERNAL_IP_ADDRESS=$1
MACHINE_NAME=camic-viewer
MACHINE_TAG=http-server
MACHINE_DESC="camicroscope viewer server for dev"
PROJECT=isb-cgc
CV_USER=cvproc
USER_AND_MACHINE=${CV_USER}@${MACHINE_NAME}
ZONE=us-central1-c
BUCK_SUFF=
TARGET_BRANCH=dev
UDU_DEPLOY_BUCKET=your-deployment-bucket-name${BUCK_SUF}/${TARGET_BRANCH}

#
# Spin up the VM:
#

gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "n1-standard-2" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1404-lts" --project "${PROJECT}" --address="${EXTERNAL_IP_ADDRESS}"

#
# Add tag to machine:
#

sleep 10
gcloud compute instances add-tags "${MACHINE_NAME}" --tags "${MACHINE_TAG}" --project "${PROJECT}" --zone "${ZONE}"

#
# This is what you get after you log in:
#

#sleep 10
#echo "AFTER LOGIN: gsutil cp gs://${UDU_DEPLOY_BUCKET}/install-deps.sh .; chmod u+x install-deps.sh; ./install-deps.sh"

#
# By logging in as a user, the machine will create an account for that user:
#

sleep 10
#gcloud compute ssh --project "${PROJECT}" --zone ${ZONE} "${USER_AND_MACHINE}"
gcloud compute scp ./build/install_deps.sh "${USER_AND_MACHINE}":/home/"${CV_USER}" --zone "${ZONE}" --project "${PROJECT}"
gcloud compute ssh --zone "${ZONE}" "${USER_AND_MACHINE}" -- '/home/'"${CV_USER}"'/install_deps.sh'
