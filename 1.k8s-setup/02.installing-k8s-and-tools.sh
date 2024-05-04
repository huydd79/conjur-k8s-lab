#/bin/sh

set -x

#Disable swap and SELinux
bk_file=/etc/fstab.bk.$(date +%s)
mv /etc/fstab $bk_file
cat $bk_file | grep -v swap > /etc/fstab
echo "#$(cat $bk_file | grep swap)" >> /etc/fstab
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
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum -y install kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet
systemctl start kubelet

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
