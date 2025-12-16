#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Worker Role Cleanup/Reset Script
# Script: u3.cleanup.worker.sh
# Target: The Node running the Single-Node Cluster
# Purpose: Resets the entire Kubernetes state (Master/Worker roles) on this node.
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

echo -e "${YELLOW}--- 🗑️ Starting Full Cluster Reset (Master & Worker Roles) ---${NC}"

# -----------------------------------------------------------------------------
# PART 1: KUBEADM RESET (REQUIRED FOR FULL CLUSTER REMOVAL)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Running kubeadm reset to remove Kubernetes state...${NC}"

if command -v kubeadm &> /dev/null
then
    # Use kubeadm reset to clean up all Kubernetes configurations created by init/join
    # This action resets BOTH the Master and the Worker roles simultaneously.
    sudo kubeadm reset -f

    # Restart kubelet
    echo -e "${YELLOW}Restarting Kubelet service...${NC}"
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    
else
    echo -e "${RED}ERROR: kubeadm not found. Cannot perform reset.${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# PART 2: NODE OBJECT REMOVAL (Cleanup API Server State)
# -----------------------------------------------------------------------------
# Although kubeadm reset should remove the Node, we attempt to delete the Node 
# object from the API server (if kubeconfig still exists) to be absolutely sure.
if [ -f $HOME/.kube/config ]; then
    NODE_NAME=$(hostname | tr '[:upper:]' '[:lower:]')
    echo -e "\n${BLUE}## 2. Draining and deleting node from Control Plane...${NC}"

    # Delete the node object from the cluster
    echo -e "${YELLOW}Deleting node object ${NODE_NAME}...${NC}"
    kubectl delete node $NODE_NAME 2>/dev/null
    
    # Clean up user configuration
    echo -e "${YELLOW}Removing user's kubeconfig directory: $HOME/.kube/${NC}"
    rm -rf $HOME/.kube
fi


# -----------------------------------------------------------------------------
# PART 3: FINAL STATUS
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}--- ✅ Cluster Reset Completed (u3 equivalent) ---${NC}"
echo -e "${YELLOW}The node has been fully reset. Since u2.cleanup.master.sh and u3.cleanup.worker.sh are identical in a single-node setup, you can use either one.${NC}"
echo -e "You can now safely rerun script 02.setup.master.sh to start over.${NC}"