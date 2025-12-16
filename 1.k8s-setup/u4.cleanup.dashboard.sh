#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Dashboard Cleanup Script
# Script: u4.cleanup.dashboard.sh
# Target: Master Node
# Purpose: Deletes the Kubernetes Dashboard components and Namespace.
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

# --- Configuration Variables ---
NAMESPACE="kubernetes-dashboard"
SA_ADMIN_NAME="dashboard-admin"
CRB_ADMIN_NAME="dashboard-admin"

echo -e "${YELLOW}--- 🗑️ Starting Kubernetes Dashboard Cleanup ---${NC}"

# --- Check Prerequisites ---
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}ERROR: kubectl not found. Cannot perform cleanup.${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# PART 1: DELETE CLUSTER-WIDE OBJECTS (ClusterRoleBinding)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Deleting ClusterRoleBinding for Dashboard Admin...${NC}"

if kubectl get clusterrolebinding $CRB_ADMIN_NAME &> /dev/null; then
    echo -e "${YELLOW}Deleting ClusterRoleBinding: $CRB_ADMIN_NAME...${NC}"
    if ! kubectl delete clusterrolebinding $CRB_ADMIN_NAME; then
        echo -e "${RED}WARNING: Failed to delete ClusterRoleBinding $CRB_ADMIN_NAME.${NC}"
    fi
else
    echo -e "${YELLOW}ClusterRoleBinding $CRB_ADMIN_NAME not found. Skipping.${NC}"
fi

# -----------------------------------------------------------------------------
# PART 2: DELETE THE NAMESPACE
# -----------------------------------------------------------------------------
# Deleting the Namespace recursively removes all objects within it (Deployments, Services, Secrets, SAs).
echo -e "\n${BLUE}## 2. Deleting Namespace $NAMESPACE and all contained resources...${NC}"

if kubectl get namespace $NAMESPACE &> /dev/null; then
    echo -e "${YELLOW}Initiating deletion of namespace $NAMESPACE. This may take a moment...${NC}"
    
    # Force deletion (optional but helps if stuck) and wait
    if ! kubectl delete namespace $NAMESPACE --wait=true --timeout=120s; then
        echo -e "${RED}WARNING: Namespace deletion failed or timed out. Check manually: kubectl get ns $NAMESPACE.${NC}"
    fi
else
    echo -e "${YELLOW}Namespace $NAMESPACE not found. Skipping namespace deletion.${NC}"
fi

# -----------------------------------------------------------------------------
# PART 3: VERIFICATION
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 3. Verification...${NC}"

# Wait a few seconds for the namespace deletion to propagate
sleep 5

if kubectl get namespace $NAMESPACE &> /dev/null; then
    echo -e "${RED}FAILURE: Namespace $NAMESPACE still exists or is stuck in Terminating state.${NC}"
else
    echo -e "${GREEN}SUCCESS: Namespace $NAMESPACE (and all Dashboard resources) successfully deleted.${NC}"
fi

echo -e "\n${GREEN}--- ✅ Kubernetes Dashboard Cleanup Completed ---${NC}"
echo -e "${YELLOW}The cluster is now reset to its pre-Dashboard state.${NC}"