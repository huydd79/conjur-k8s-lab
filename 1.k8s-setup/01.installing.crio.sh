#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Deployment Script for CentOS 9 Stream using CRI-O
# Script: 01.installing.crio.sh
# Target: All Control Plane and Worker Nodes
# -----------------------------------------------------------------------------

# Define ANSI color codes for easier reading of output
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
NC='\033[0m' # No Color (Reset)

# --- Configuration Variables ---
# Recommended versions for modern K8s deployment
CRIO_VERSION="v1.30"
K8S_VERSION="v1.30"
OS_VERSION="CentOS_9_Stream" # Used for some repository paths

echo -e "${GREEN}--- 🛠️ Starting K8s/CRI-O Installation on CentOS 9 Stream (Version: ${K8S_VERSION}) ---${NC}"

# -----------------------------------------------------------------------------
# PART 1: SYSTEM PREREQUISITES AND KERNEL CONFIGURATION
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Setting up Kernel Modules and Sysctl Parameters...${NC}"

# Load required kernel modules for networking
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl parameters required by K8s
# These enable IP forwarding and allow iptables to see bridged traffic
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params
sudo sysctl --system

# --- Disable Swap, SELinux, and Firewall ---
echo -e "\n${BLUE}## 2. Disabling Swap, SELinux, and Firewalld...${NC}"

# Disable swap immediately and permanently
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Set SELinux to permissive mode
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Stop and disable firewalld (optional, but recommended for simplicity in lab/initial setup)
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# -----------------------------------------------------------------------------
# PART 2: INSTALLING CRI-O CONTAINER RUNTIME (Using Community OBS Link)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 3. Installing CRI-O Container Runtime (Version: ${CRIO_VERSION})...${NC}"

# Define the CRI-O repo URL based on the latest stable OBS link found
CRIO_REPO_URL="https://download.opensuse.org/repositories/isv:/kubernetes:/addons:/cri-o:/stable:/${CRIO_VERSION}/rpm/isv:kubernetes:addons:cri-o:stable:${CRIO_VERSION}.repo"

# Clean up any potential previous failed repo files
sudo rm -f /etc/yum.repos.d/crio.repo
sudo dnf clean all

# Add the CRI-O repository
echo -e "${YELLOW}Adding CRI-O repository from: ${CRIO_REPO_URL}${NC}"
curl -L -o /etc/yum.repos.d/crio.repo "${CRIO_REPO_URL}"

# Install CRI-O and cri-tools
sudo dnf install -y cri-o cri-tools

# Enable and start CRI-O service
sudo systemctl daemon-reload
sudo systemctl enable --now crio

echo -e "${YELLOW}CRI-O Installation Status (Should be 'active (running)'):${NC}"
sudo systemctl status crio --no-pager

# -----------------------------------------------------------------------------
# PART 3: INSTALLING KUBERNETES COMPONENTS (kubelet, kubeadm, kubectl)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 4. Installing Kubernetes Components (Version: ${K8S_VERSION})...${NC}"

# Add Kubernetes official repository (pkgs.k8s.io)
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install the components
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable kubelet service (kubeadm will start it later)
sudo systemctl enable --now kubelet

echo -e "\n${GREEN}--- ✅ Installation Script Completed Successfully ---${NC}"
echo -e "${YELLOW}NEXT STEP: Run 'kubeadm init' on the Control Plane node (Master) and then 'kubeadm join' on Worker nodes.${NC}"