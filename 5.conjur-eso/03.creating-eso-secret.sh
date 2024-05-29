#!/bin/bash

ESO_NS="external-secrets"


set -x
kubectl get namespace | grep -q $ESO_NS || kubectl create namespace $ESO_NS
kubectl -n $ESO_NS get externalsecret | grep -q conjur  && kubectl -n $ESO_NS delete externalsecret conjur

kubectl apply -n $ESO_NS -f yaml/conjur-external-secret.yaml

sleep 1
kubectl -n external-secrets describe externalsecret conjur
set +x
