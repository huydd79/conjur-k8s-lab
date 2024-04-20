#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

CONJUR_CERT="$(openssl s_client -showcerts -connect  conjur-master.$LAB_DOMAIN:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"
CONJUR_MASTER_URL=https://conjur-master.$LAB_DOMAIN
AUTHENTICATOR_ID=k8s
CONJUR_ACCOUNT=$LAB_CONJUR_ACCOUNT
CONJUR_SEED_FILE_URL=$CONJUR_MASTER_URL/configuration/$CONJUR_ACCOUNT/seed/follower

set -x
kubectl get namespace | grep -q conjur || kubectl create namespace conjur
kubectl -n conjur get configmap | grep -q follower-cm && kubectl -n conjur delete configmap follower-cm
kubectl -n conjur create configmap follower-cm \
    --from-literal CONJUR_ACCOUNT=$CONJUR_ACCOUNT \
    --from-literal CONJUR_APPLIANCE_URL=$CONJUR_MASTER_URL \
    --from-literal CONJUR_SEED_FILE_URL=$CONJUR_SEED_FILE_URL \
    --from-literal AUTHENTICATOR_ID=$AUTHENTICATOR_ID \
    --from-literal "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}"

set +x
