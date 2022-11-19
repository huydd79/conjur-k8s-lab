#/bin/sh

set -x

kubeadm config images pull
kubeadm init --pod-network-cidr 10.244.0.0/16

#Configure kubectl admin login and allow pods to run on master (single-node Kubernetes)
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

#Install Flannel networking
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

#Wait until cni0 up and runing
ret=1
until [ $ret -eq 0 ]
do
    echo "Waiting cni0 up and running..."
    ip address | grep -q cni0
    ret=$?
    sleep 1
done

#Wait until flannel.1 up and runing
ret=1
until [ $ret -eq 0 ]
do
    echo "Waiting flannel.1 up and running..."
    ip address | grep -q flannel.1
    ret=$?
    sleep 1
done

#Refresh cni0 until getting correct IP at 10.244.0.0
ip address show dev cni0 | grep 10.244
ret=$?
until [ $ret -eq 0 ]
do
    echo "Refreshing cni0 to get correct IP..."
    ip link del cni0
    ip link del flannel.1
    kubectl delete pod --selector=app=flannel -n kube-flannel
    kubectl delete pod --selector=k8s-app=kube-dns -n kube-system
    sleep 10
    ip address show dev cni0 | grep 10.244
    ret=$?
done 
set +x