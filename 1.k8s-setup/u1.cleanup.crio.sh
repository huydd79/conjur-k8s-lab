#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Full Cleanup Script (CRI-O/K8s Packages)
# Script: u1.cleanup.crio.sh
# Target: All Control Plane and Worker Nodes
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

echo -e "${RED}--- 🚨 Starting Full System Cleanup and Package Removal ---${NC}"

# -----------------------------------------------------------------------------
# PART 1: KUBEADM RESET (If cluster was initialized)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Running kubeadm reset (if kubeadm is installed)...${NC}"
if command -v kubeadm &> /dev/null
then
    sudo kubeadm reset -f
else
    echo -e "${YELLOW}kubeadm not found. Skipping kubeadm reset.${NC}"
fi

# -----------------------------------------------------------------------------
# PART 2: UNINSTALL KUBERNETES AND CRI-O PACKAGES
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 2. Stopping Kubelet and CRI-O services...${NC}"

sudo systemctl stop kubelet crio
sudo systemctl disable kubelet crio

echo -e "\n${BLUE}## 3. Removing K8s and CRI-O packages...${NC}"
sudo dnf remove -y kubelet kubeadm kubectl cri-o cri-tools --disableexcludes=kubernetes

# -----------------------------------------------------------------------------
# PART 3: CLEANUP CONFIGURATION AND SYSTEM FILES
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 4. Cleaning up Kubernetes directories and configuration...${NC}"

# Remove configuration directories
sudo rm -rf /etc/kubernetes/
sudo rm -rf $HOME/.kube
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/cni/*
sudo rm -rf /etc/cni/net.d/*

# Remove Kubernetes repo file
sudo rm -f /etc/yum.repos.d/kubernetes.repo
sudo rm -f /etc/yum.repos.d/crio.repo

# -----------------------------------------------------------------------------
# PART 4: RESTORE SYSTEM PREREQUISITES
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 5. Restoring System Configurations (Swap, SELinux, Sysctl)...${NC}"

# Re-enable swap (comment out the sed operation, if desired, or manually remove swap entries from fstab)
# For simplicity, we just enable swap again if desired, but Kubernetes best practice is to keep it off.
# sudo swapon -a

# Set SELinux back to enforcing (Optional, based on original system state)
# sudo setenforce 1
# sudo sed -i 's/^SELINUX=permissive$/SELINUX=enforcing/' /etc/selinux/config

# Remove k8s sysctl config
sudo rm -f /etc/sysctl.d/k8s.conf
sudo sysctl --system # Apply system defaults

# Remove kernel modules configuration
sudo rm -f /etc/modules-load.d/k8s.conf
sudo modprobe -r overlay
sudo modprobe -r br_netfilter

echo -e "\n${GREEN}--- ✅ Full System Cleanup Completed ---${NC}"
echo -e "${YELLOW}The node is now reset to pre-Kubernetes state.${NC}"