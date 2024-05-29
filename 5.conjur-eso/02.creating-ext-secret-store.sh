#!/bin/bash

source ../2.conjur-setup/00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

ESO_NS="external-secrets"
CONJUR_FOLLOWER_URL="https:\/\/follower.conjur.svc.cluster.local"
CONJUR_CERT="$(openssl s_client -showcerts -connect  conjur-master.$LAB_DOMAIN:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

YML_FILE="./yaml/conjur-secret-store-jwt.yaml"
YML_TEMP="/tmp/$(date +%s).yaml"

set -x

kubectl get namespace | grep -q $ESO_NS || kubectl create namespace $ESO_NS

#Reset config map
kubectl -n $ESO_NS get configmap | grep -q conjur-cm && kubectl -n $ESO_NS delete configmap conjur-cm
kubectl -n $ESO_NS create configmap conjur-cm \
    --from-literal "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}"

#Prepare manifest
cp $YML_FILE $YML_TEMP
sed -i "s/{CONJUR_URL}/$CONJUR_FOLLOWER_URL/g" $YML_TEMP
sed -i "s/{CONJUR_ACCOUNT}/$LAB_CONJUR_ACCOUNT/g" $YML_TEMP

kubectl -n $ESO_NS get secretstore | grep -q conjur && kubectl -n $ESO_NS delete secretstore conjur
kubectl apply -n $ESO_NS -f $YML_TEMP
rm -rf $YML_TEMP

kubectl -n $ESO_NS get secretstore -o json | jq


set +x
