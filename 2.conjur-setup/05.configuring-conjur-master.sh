#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
masterContainer=$node_name
serverType="master"
masterDNS="conjur-master.$LAB_DOMAIN"
clusterDNS="conjur-master.$LAB_DOMAIN"
standby1DNS="$node_name.$LAB_DOMAIN"
adminPass=$LAB_CONJUR_ADMIN_PW
accountName=$LAB_CONJUR_ACCOUNT
podman exec $masterContainer evoke configure $serverType \
    --accept-eula -h $masterDNS \
    --master-altnames "$clusterDNS,$standby1DNS" \
    -p $adminPass $accountName
set +x