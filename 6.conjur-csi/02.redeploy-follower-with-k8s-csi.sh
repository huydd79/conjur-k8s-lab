
#/bin/sh
source ../2.conjur-setup/00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x

#Delete current deployment
kubectl -n conjur get deployments | grep -q follower
if [ $? -eq 0 ]; then
    kubectl -n conjur delete deployment follower
    ret=0
    until [ $ret -ne 0 ]
    do
        kubectl -n conjur get deployments | grep -q follower
        ret=$?
        echo "Waiting deployment is deleted..."
        sleep 1
    done
    
fi

cp yaml/02.follower-with-csi.yaml /tmp/follower.yaml
sed -i "s/CONJUR_IP/$CONJUR_IP/g" /tmp/follower.yaml
sed -i "s/LAB_DOMAIN/$LAB_DOMAIN/g" /tmp/follower.yaml
sed -i "s/CONJUR_VERSION/$conjur_version/g" /tmp/follower.yaml

kubectl -n conjur apply -f /tmp/follower.yaml

rm /tmp/follower.yaml
set +x
