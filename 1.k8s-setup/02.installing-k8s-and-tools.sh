#/bin/sh

set -x

#Disable swap and SELinux
swapoff -a
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#Configure required kernel modules and tunables
cat <<EOF >> /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter
cat <<EOF >> /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#Install kubeadm, kubelet and kubectl
cat <<EOF >> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
yum -y install kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

#Configure firewall
firewall-cmd --add-port 2379-2380/tcp --permanent
firewall-cmd --add-port 6443/tcp --permanent
firewall-cmd --add-port 8472/udp --permanent
firewall-cmd --add-port 10250/tcp --permanent
firewall-cmd --add-port 10257/tcp --permanent
firewall-cmd --add-port 10259/tcp --permanent
firewall-cmd --add-port 30000-32767/tcp --permanent
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload

set +x