#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

APP_NAME="cityapp-conjurtok8sfile"
YML_FILE="yaml/$APP_NAME.yaml"
YML_TEMP="/tmp/$APP_NAME.yaml"
CONJUR_FOLLOWER_URL="https://follower.conjur.svc.cluster.local"
CONJUR_CERT="$(openssl s_client -showcerts -connect  conjur-master.demo.local:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

CONJUR_AUTHN_URL=$CONJUR_FOLLOWER_URL/authn-jwt/k8s
set -x
kubectl get namespace | grep -q cityapp || kubectl create namespace cityapp
#Reset config map


kubectl -n cityapp get configmap | grep -q apps-cm && kubectl -n cityapp delete configmap apps-cm
kubectl -n cityapp create configmap apps-cm \
    --from-literal CONJUR_ACCOUNT=$LAB_CONJUR_ACCOUNT \
    --from-literal CONJUR_APPLIANCE_URL=$CONJUR_FOLLOWER_URL \
    --from-literal CONJUR_AUTHN_URL=$CONJUR_AUTHN_URL \
    --from-literal "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}"

#Delete current deployment
kubectl -n cityapp get deployments | grep -q $APP_NAME
if [ $? -eq 0 ]; then
    kubectl -n cityapp delete deployment $APP_NAME
    ret=0
    until [ $ret -ne 0 ]
    do
        kubectl -n cityapp get deployments | grep -q $APP_NAME
        ret=$?
        echo "Waiting deployment is deleted..."
        sleep 1
    done
    
fi
cp $YML_FILE $YML_TEMP
sed -i "s/{LAB_IP}/$LAB_IP/g" $YML_TEMP
sed -i "s/{LAB_DOMAIN}/$LAB_DOMAIN/g" $YML_TEMP

kubectl -n cityapp apply -f $YML_TEMP

rm $YML_TEMP
set +x