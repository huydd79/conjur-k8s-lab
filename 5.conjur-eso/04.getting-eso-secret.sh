#!/bin/bash

ESO_NS="external-secrets"


set -x

kubectl -n external-secrets describe externalsecret conjur
sleep 1
kubectl -n $ESO_NS get secret conjur -o jsonpath="{.data}" | jq

set +x
