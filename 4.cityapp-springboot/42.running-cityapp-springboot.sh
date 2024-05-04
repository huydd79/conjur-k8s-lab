#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

APP_NAME="cityapp-springboot"
YML_FILE="yaml/$APP_NAME.yaml"
YML_TEMP="/tmp/$APP_NAME.yaml"

CONJUR_URL="https://conjur-master.$LAB_DOMAIN"
CONJUR_CERT="$(openssl s_client -showcerts -connect  conjur-master.$LAB_DOMAIN:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

CONJUR_AUTHN_URL=$CONJUR_URL/authn-jwt/k8s

set -x

kubectl get namespace | grep -q cityapp || kubectl create namespace cityapp
#Reset config map
kubectl -n cityapp get configmap | grep -q apps-springboot-cm && kubectl -n cityapp delete configmap apps-springboot-cm
kubectl -n cityapp create configmap apps-springboot-cm \
    --from-literal CONJUR_ACCOUNT=$LAB_CONJUR_ACCOUNT \
    --from-literal CONJUR_APPLIANCE_URL=$CONJUR_URL \
    --from-literal "CONJUR_SSL_CERTIFICATE=${CONJUR_CERT}" \

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

#Prepare manifest
cp $YML_FILE $YML_TEMP
sed -i "s/{LAB_IP}/$LAB_IP/g" $YML_TEMP
sed -i "s/{LAB_DOMAIN}/$LAB_DOMAIN/g" $YML_TEMP

#Deploy pod
kubectl -n cityapp apply -f $YML_TEMP

rm $YML_TEMP
set +x