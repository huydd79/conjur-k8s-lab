#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
conjur -d policy load -f ./policies/root-policy.yaml -b root
conjur -d policy load -f ./policies/demo-data.yaml -b root
conjur variable set -i test/host1/host -v mysql.$LAB_DOMAIN
conjur variable set -i test/host1/user -v cityapp
conjur variable set -i test/host1/pass -v Cyberark1
set +x

