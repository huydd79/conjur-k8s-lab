#/bin/sh

set -x

kubectl apply -f yaml/kube-dashboard.yaml

kubectl apply -f yaml/dashboard-serviceaccount.yaml

kubectl -n kubernetes-dashboard describe secrets dashboard-admin-secret
echo "Please copy above token value for dashboard login. Press enter when done..."
read
set +x