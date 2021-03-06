#!/usr/bin/env bash
set -x

if [ "$#" -ne 1 ]; then
    echo "Usage: ./$PROGNAME <prod|dev|test|uat>"
    exit 1;
fi

#Set this according to the branch being developed/executed
BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

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

    declare -a arr2=('dev','prod')

    if [[ ${arr2[*]} =~ $1 ]]
    then
	CONFIG_BUCKET=web-app-deployment-files/$1
    else
	CONFIG_BUCKET=webapp-deployment-files-$1
    fi

    if [ $1 == 'prod' ]
    then
	WEBAPP=isb-cgc.appspot.com
    elif [ $1 == 'dev' ]
    then
	WEBAPP=mvm-dot-isb-cgc.appspot.com
    elif [ $1 == 'test' ]
    then
	WEBAPP=isb-cgc-test.appspot.com
    else 
	WEBAPP=isb-cgc-uat.appspot.com
    fi

    if [ $1 == 'prod' ]
    then
	MACHINE_TYPE="n1-standard-2"
    else
	MACHINE_TYPE="n1-standard-1"
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

MACHINE_TAGS=camic-viewer-vm,http-server,ssh-from-whc,http-from-whc
BASE_NAME=camic-viewer
STATIC_IP_ADDRESS=$BASE_NAME-$1
MACHINE_NAME=$BASE_NAME-$1
MACHINE_DESC="camicroscope viewer server for "$1
MACHINE_URL=$MACHINE_NAME.isb-cgc.org
CV_USER=cvproc
USER_AND_MACHINE=${CV_USER}@${MACHINE_NAME}
VM_REGION=us-west1
ZONE=$VM_REGION-b
IP_REGION=us-central1
IP_SUBNET=${IP_REGION}

#
# Create static external IP address if not already existan
addresses=$(gcloud compute addresses list --project $PROJECT|grep $STATIC_IP_ADDRESS)
if [ -z "$addresses" ]
then
    gcloud compute addresses create $STATIC_IP_ADDRESS --region $VM_REGION --project $PROJECT
fi

#
# Delete existing VM, then spin up the new one:
#
instances=$(gcloud compute instances list --project $PROJECT --filter="zone:(us-west1-b)"|grep $MACHINE_NAME)
if [ -n "$instances" ]
then
    gcloud compute instances delete -q "${MACHINE_NAME}" --zone "${ZONE}" --project "${PROJECT}"
fi
gcloud compute instances create "${MACHINE_NAME}" --description "${MACHINE_DESC}" --zone "${ZONE}" --machine-type "${MACHINE_TYPE}" --image-project "ubuntu-os-cloud" --image-family "ubuntu-1804-lts" --project "${PROJECT}" --address="${STATIC_IP_ADDRESS}" --scopes=default,storage-rw
#fi

#
# Add network tags to machine:
#
sleep 10
if [ -n "$MACHINE_TAGS" ]
then
    gcloud compute instances add-tags "${MACHINE_NAME}" --tags="${MACHINE_TAGS}" --project "${PROJECT}" --zone "${ZONE}"
fi

#
# Copy and run a config script
#
sleep 10
gcloud compute scp $(dirname $0)/install_deps.sh "${USER_AND_MACHINE}":/home/"${CV_USER}" --zone "${ZONE}" --project "${PROJECT}"
gcloud compute ssh --zone "${ZONE}" --project "${PROJECT}" "${USER_AND_MACHINE}" -- '/home/'"${CV_USER}"'/install_deps.sh' "${BRANCH}" "${MACHINE_URL}" "${CONFIG_BUCKET}" "${WEBAPP}" "${PROJECT}"
