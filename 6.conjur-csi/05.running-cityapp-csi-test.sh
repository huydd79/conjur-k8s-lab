#/bin/sh

APP_NAME="cityapp-csi"

set -x
kubectl get namespace | grep -q cityapp || kubectl create namespace cityapp
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


kubectl -n cityapp apply -f ./yaml/05.$APP_NAME.yaml

set +x