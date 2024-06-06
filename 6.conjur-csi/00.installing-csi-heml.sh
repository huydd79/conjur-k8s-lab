#!/bin/bash


set -x

echo "Installing helm if not available..."
which helm > /dev/null 2>&1
if [ $? -ne 0 ]; then 
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    bash ./get_helm.sh
    rm ./get_helm.sh
else
    echo "Helm has been already installed!!!"
fi

echo "Installing Secrets Store CSI Driver using Helm..."
helm list -n kube-system | grep -q csi-secrets-store
if [ $? -ne 0 ]; then 
    helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
    helm install csi-secrets-store \
	secrets-store-csi-driver/secrets-store-csi-driver \
	--wait \
	--namespace kube-system \
	--set syncSecret.enabled="false" \
	--set 'tokenRequests[0].audience=conjur'
else
    echo "Helm chart for csi-secrets-store has been installed"
    echo "Delete it with command: helm delete -n kube-system csi-secrets-store"
fi


kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"

set +x
