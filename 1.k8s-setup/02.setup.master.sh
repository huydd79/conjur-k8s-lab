#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Control Plane Initialization Script
# Script: 02.setup.master.sh
# Target: ONLY the Master (Control Plane) Node
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

# --- Configuration Variables ---
# Get the first private IP address of the machine
MASTER_IP_ADDRESS=$(hostname -I | awk '{print $1}')
CNI_CALICO_URL="https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml"

# CNI Network CIDR (Updated to user's specified range)
POD_NETWORK_CIDR="10.224.0.0/16" 

echo -e "${GREEN}--- 🚀 Starting Control Plane Initialization ---${NC}"

# --- Input Validation ---
if [ -z "$MASTER_IP_ADDRESS" ]; then
  echo -e "${RED}ERROR: Could not automatically determine the Master IP Address.${NC}"
  echo -e "${YELLOW}Please set it manually in the script.${NC}"
  exit 1
fi

echo -e "${YELLOW}MASTER IP Detected: ${MASTER_IP_ADDRESS}${NC}"
echo -e "${YELLOW}POD CIDR: ${POD_NETWORK_CIDR}${NC}"

# -----------------------------------------------------------------------------
# PART 1: KUBEADM INIT - INITIALIZE THE CLUSTER
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Initializing Kubernetes Control Plane with kubeadm...${NC}"

if ! command -v kubeadm &> /dev/null
then
    echo -e "${RED}ERROR: kubeadm is not installed. Did script 01 run successfully?${NC}"
    exit 1
fi

# Run kubeadm init
sudo kubeadm init \
  --apiserver-advertise-address=$MASTER_IP_ADDRESS \
  --pod-network-cidr=$POD_NETWORK_CIDR \
  --cri-socket=unix:///var/run/crio/crio.sock \
  --upload-certs

if [ $? -ne 0 ]; then
    echo -e "${RED}FATAL: kubeadm init failed. Check logs (journalctl -u kubelet).${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# PART 2: CONFIGURE KUBECONFIG FOR USER
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 2. Configuring Kubeconfig for current user (${USER})...${NC}"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# -----------------------------------------------------------------------------
# PART 3: INSTALL CONTAINER NETWORK INTERFACE (CNI - CALICO)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 3. Installing Calico CNI Plugin (Network setup)...${NC}"

# Wait briefly for cluster components to start up before applying CNI
sleep 5

# NOTE: We need to modify the Calico manifest to match the custom POD_NETWORK_CIDR (10.224.0.0/16)
echo -e "${YELLOW}Downloading Calico manifest and patching for custom CIDR (${POD_NETWORK_CIDR})...${NC}"

curl -L $CNI_CALICO_URL -o calico.yaml

# Patch the calico.yaml to use the specified POD_NETWORK_CIDR
sed -i "s|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|g" calico.yaml
sed -i "s|#   value: \"192.168.0.0/16\"|  value: \"$POD_NETWORK_CIDR\"|g" calico.yaml

# Apply the patched Calico manifest
kubectl apply -f calico.yaml

echo -e "${YELLOW}Waiting for CoreDNS and Calico pods to start... (This may take 1-2 minutes)${NC}"

# Wait for core DNS to be ready
kubectl wait --for=condition=ready pod -l k8s-app=kube-dns -n kube-system --timeout=300s

# Clean up the manifest file
rm calico.yaml

# -----------------------------------------------------------------------------
# PART 4: FINAL VERIFICATION AND NEXT STEPS
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}--- ✅ Control Plane Initialization Complete ---${NC}"

echo -e "\n${YELLOW}Node Status (Master should be 'Ready' soon):${NC}"
kubectl get nodes

echo -e "\n${YELLOW}System Pods Status:${NC}"
kubectl get pods -n kube-system

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${YELLOW}IMPORTANT: SAVE THE KUBEADM JOIN COMMAND FOR WORKER NODES!${NC}"
echo -e "Run the following command on all Worker Nodes to join the cluster:${NC}"
# Extract and display the join command again (may require running under sudo or root)
sudo kubeadm token create --print-join-command 2>/dev/null
echo -e "${BLUE}================================================================${NC}"