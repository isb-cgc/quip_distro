#!/usr/bin/env bash
#set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: ./$PROGNAME <prod|dev|test|uat>"
    exit 1;
fi

#arr = ['prod','dev','test','uat']
declare -a arr=('prod' 'dev' 'test' 'uat')
if [[ ${arr[*]} =~ $1 ]]
then
    declare -a arr1=('prod','dev')

    if [[ ${arr1[*]} =~ $1 ]]
    then
	PROJECT=isb-cgc
    else
	PROJECT=isb-cgc-$1
    fi
else
    echo "Usage: ./$PROGNAME <prod|dev|test|uat> <<external IP address>"
    exit 1;
fi

#if [ $1 == 'uat' ]
#then
#	MACHINE_TAG=
#else
#	MACHINE_TAG=http-server
#fi

MACHINE_TAG=camic-viewer-vm
BASE_NAME=camic-viewer
EXTERNAL_IP_ADDRESS=$BASE_NAME-$1
MACHINE_NAME=$BASE_NAME-$1
MACHINE_DESC="camicroscope viewer server for "$1
CV_USER=cvproc
USER_AND_MACHINE=${CV_USER}@${MACHINE_NAME}
REGION=us-west1
ZONE=$REGION-b

#
# Create static external IP address if not already existan
addresses=$(gcloud compute addresses list --project $PROJECT|grep $EXTERNAL_IP_ADDRESS)
if [ -z "$addresses" ]
then
    gcloud compute addresses create $EXTERNAL_IP_ADDRESS --region $REGION --project $PROJECT
fi
#
# Delete existing VM, then spin up the new one:
#
instances=$(gcloud compute instances list --project $PROJECT --filter="zone:(us-west1-b)"|grep $MACHINE_NAME)
if [ -n "$instances" ]
then
    gcloud compute instances delete -q "${MACHINE_NAME}" --zone "${ZONE}" --project "${PROJECT}"
fi
gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "n1-standard-2" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1404-lts" --project "${PROJECT}" --address="${EXTERNAL_IP_ADDRESS}"
#fi

#
# Add tag to machine:
#
sleep 10
if [ -n "$MACHINE_TAG" ]
then
    gcloud compute instances add-tags "${MACHINE_NAME}" --tags "${MACHINE_TAG}" --project "${PROJECT}" --zone "${ZONE}"
fi

#
# Copy and run a config script
#
sleep 10
gcloud compute scp $(dirname $0)/install_deps.sh "${USER_AND_MACHINE}":/home/"${CV_USER}" --zone "${ZONE}" --project "${PROJECT}"
gcloud compute ssh --zone "${ZONE}" --project "${PROJECT}" "${USER_AND_MACHINE}" -- '/home/'"${CV_USER}"'/install_deps.sh'
