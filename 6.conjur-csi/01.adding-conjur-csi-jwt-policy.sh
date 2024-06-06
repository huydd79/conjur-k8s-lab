#!/bin/bash

set -x
conjur -d policy load -f ./yaml/01.conjur-csi-jwt-policy.yaml -b root

PUBLIC_KEYS="$(kubectl get --raw $(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri'))"
ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"
conjur variable set -i conjur/authn-jwt/k8s-csi/public-keys -v "{\"type\":\"jwks\", \"value\":$PUBLIC_KEYS}"
conjur variable set -i conjur/authn-jwt/k8s-csi/issuer -v $ISSUER

conjur variable set -i test/host2/host -v testcsi.demo.local
conjur variable set -i test/host2/user -v test-csi-user
conjur variable set -i test/host2/pass -v SecureP@s5

set +x
