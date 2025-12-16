#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Single-Node Conversion Script (Master -> Master/Worker)
# Script: 03.setup.worker.sh
# Target: The Master Node itself (to enable scheduling of Pods)
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

echo -e "${GREEN}--- 🤝 Starting Single-Node Conversion (Master -> Master/Worker) ---${NC}"

# --- Check Prerequisites ---
if ! command -v kubectl &> /dev/null
then
    echo -e "${RED}ERROR: kubectl not found. Please ensure 02.setup.master.sh ran successfully.${NC}"
    exit 1
fi

if [ ! -f $HOME/.kube/config ]; then
    echo -e "${RED}ERROR: Kubeconfig not found. Please run 02.setup.master.sh first.${NC}"
    exit 1
fi

NODE_NAME=$(hostname | tr '[:upper:]' '[:lower:]')

# -----------------------------------------------------------------------------
# PART 1: REMOVE MASTER TAINT (Enable Pod Scheduling)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Waiting for Node to be Ready...${NC}"

# Wait for the node to reach Ready state after CNI setup
echo -e "${YELLOW}Waiting for node $NODE_NAME to be READY...${NC}"
kubectl wait --for=condition=Ready node/$NODE_NAME --timeout=300s || { 
    echo -e "${RED}FATAL: Node ${NODE_NAME} did not reach Ready state within timeout.${NC}"; 
    exit 1; 
}

echo -e "\n${BLUE}## 2. Removing Master Taint to enable Pod scheduling...${NC}"

# Remove the default taint applied to the Master node.
# The taint is node-role.kubernetes.io/control-plane:NoSchedule (or /master:NoSchedule for older K8s versions)
echo -e "${YELLOW}Executing: kubectl taint node $NODE_NAME node-role.kubernetes.io/control-plane:NoSchedule-${NC}"
kubectl taint node $NODE_NAME node-role.kubernetes.io/control-plane:NoSchedule-

if [ $? -ne 0 ]; then
    echo -e "${RED}FATAL: Failed to remove taint from node ${NODE_NAME}.${NC}"
    exit 1
fi

echo -e "${YELLOW}Successfully removed taint: Pods can now be scheduled on the Master Node.${NC}"

# -----------------------------------------------------------------------------
# PART 2: VERIFICATION
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 3. Final Verification...${NC}"

# Check node status and roles
echo -e "\n${GREEN}--- ✅ Single-Node Setup Completed ---${NC}"
echo -e "${YELLOW}Node Status (Should show 'control-plane,master' and READY):${NC}"
kubectl get nodes -o wide