#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
curl -s -LOJ https://github.com/cyberark/conjur-api-python3/releases/download/v7.0.1/conjur-cli-rhel-8.tar.gz
tar xvf conjur-cli-rhel-8.tar.gz
chmod 755 ./conjur
cp ./conjur /usr/local/bin
conjur init -u https://conjur-master.$LAB_DOMAIN
conjur login -i admin
set +x
conjur whoami

