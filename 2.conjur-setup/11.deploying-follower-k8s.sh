
#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
cp follower/follower.yaml /tmp/follower.yaml
sed -i "s/CONJUR_IP/$CONJUR_IP/g" /tmp/follower.yaml
sed -i "s/LAB_DOMAIN/$LAB_DOMAIN/g" /tmp/follower.yaml
sed -i "s/CONJUR_VERSION/$conjur_version/g" /tmp/follower.yaml

kubectl -n conjur apply -f /tmp/follower.yaml

rm /tmp/follower.yaml
set +x
