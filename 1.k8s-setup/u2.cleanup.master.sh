#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Master Role Cleanup/Reset Script
# Script: u2.cleanup.master.sh
# Target: ONLY the Master (Control Plane) Node
# Purpose: Resets the node after kubeadm init/join, keeping K8s packages installed.
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

echo -e "${YELLOW}--- 🗑️ Starting Master Role Cleanup/Reset ---${NC}"

# -----------------------------------------------------------------------------
# PART 1: KUBEADM RESET
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Running kubeadm reset...${NC}"

if command -v kubeadm &> /dev/null
then
    # Use kubeadm reset to clean up all Kubernetes configurations created by init/join
    sudo kubeadm reset -f

    # Restart kubelet (necessary after kubeadm reset)
    echo -e "${YELLOW}Restarting Kubelet service...${NC}"
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    
else
    echo -e "${RED}ERROR: kubeadm not found. Cannot perform reset.${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# PART 2: CLEANUP KUBECONFIG AND CONFIGURATION FILES
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 2. Cleaning up Kubeconfig and configuration files...${NC}"

# Remove the user's kubeconfig file
echo -e "${YELLOW}Removing user's kubeconfig directory: $HOME/.kube/${NC}"
rm -rf $HOME/.kube

# Remove configuration files and directories created by init
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf /etc/kubernetes/pki/*
sudo rm -f /etc/kubernetes/admin.conf

# Clean up the Calico manifest file downloaded during the process
echo -e "${YELLOW}Removing local Calico manifest file (calico.yaml)...${NC}"
rm -f calico.yaml

# -----------------------------------------------------------------------------
# PART 3: CNI/Container Cleanup
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 3. Cleaning up leftover Pod/Container data...${NC}"

# Stop and remove old pods/containers (using crictl if crio is running)
if command -v crictl &> /dev/null
then
    echo -e "${YELLOW}Stopping and removing all existing containers...${NC}"
    crictl stop $(crictl ps -q) 2>/dev/null
    crictl rm $(crictl ps -a -q) 2>/dev/null
fi

# Remove CNI network configuration and data
echo -e "${YELLOW}Removing CNI network configuration and data...${NC}"
# Delete bridge interfaces created by CNI (if any persist)
ip link show | grep cni | awk '{print $2}' | sed 's/.$//' | xargs -r -I {} sudo ip link delete {}
sudo rm -rf /var/lib/cni/*
sudo rm -rf /etc/cni/net.d/*

echo -e "\n${GREEN}--- ✅ Master Role Cleanup/Reset Completed ---${NC}"
echo -e "${YELLOW}You can now safely rerun script 02.setup.master.sh.${NC}"