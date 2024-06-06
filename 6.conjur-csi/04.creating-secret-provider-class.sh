#!/bin/bash

source ../2.conjur-setup/00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

CONJUR_FOLLOWER_URL="https:\/\/follower.conjur.svc.cluster.local"
CONJUR_CERT="$(openssl s_client -showcerts -connect  conjur-master.$LAB_DOMAIN:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

YML_FILE="./yaml/04.conjur-csi-provider-class-config.yaml"
YML_TEMP="/tmp/$(date +%s).yaml"

OBJ_TYPE=" SecretProviderClass"
OBJ_NAME="conjur-credentials"
OBJ_NS="cityapp"

set -x

kubectl -n $OBJ_NS get $OBJ_TYPE | grep -q $OBJ_NAME
if [ $? -eq 0 ]; then
    kubectl -n $OBJ_NS delete $OBJ_TYPE $OBJ_NAME
    ret=0
    until [ $ret -ne 0 ]
    do
        kubectl -n $OBJ_NS get $OBJ_TYPE | grep -q $OBJ_NAME
        ret=$?
        echo "Waiting $OBJ_TYPE is deleted..."
        sleep 1
    done

fi

#Prepare manifest
cp $YML_FILE $YML_TEMP
sed -i "s/{CONJUR_URL}/$CONJUR_FOLLOWER_URL/g" $YML_TEMP
sed -i "s/{CONJUR_ACCOUNT}/$LAB_CONJUR_ACCOUNT/g" $YML_TEMP

set +x
while read -r line; do
    echo "      $line" >> $YML_TEMP
done <<< "$CONJUR_CERT"
set -x

kubectl -n $OBJ_NS apply -f $YML_TEMP

rm -rf $YML_TEMP

kubectl -n $OBJ_NS describe $OBJ_TYPE $OBJ_NAME

set +x
