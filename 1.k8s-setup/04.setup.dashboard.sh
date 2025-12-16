#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes (K8s) Dashboard Deployment Script
# Script: 04.setup.dashboard.sh
# Target: Master Node
# -----------------------------------------------------------------------------

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

# --- Configuration Variables ---
DASHBOARD_YAML="yaml/kube-dashboard.yaml"
SA_YAML="yaml/dashboard-serviceaccount.yaml"
NAMESPACE="kubernetes-dashboard"
DASHBOARD_DEPLOYMENT="kubernetes-dashboard"
METRICS_DEPLOYMENT="dashboard-metrics-scraper"
# Tên Secret mà bạn đã định nghĩa trong dashboard-serviceaccount.yaml
TOKEN_SECRET_NAME="dashboard-admin-secret" 

echo -e "${GREEN}--- 📊 Starting Kubernetes Dashboard Deployment ---${NC}"

# --- Check Prerequisites ---
if [ ! -f "$DASHBOARD_YAML" ] || [ ! -f "$SA_YAML" ]; then
    echo -e "${RED}ERROR: Required YAML files not found. Please ensure both $DASHBOARD_YAML and $SA_YAML exist.${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}ERROR: kubectl not found. Ensure K8s is initialized and configured.${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# PART 1: CLEANUP EXISTING DEPLOYMENTS (Idempotent Setup)
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 1. Ensuring previous Dashboard components are cleaned up...${NC}"

declare -a DEPLOYMENTS=("$DASHBOARD_DEPLOYMENT" "$METRICS_DEPLOYMENT")

# Cleanup Deployments
for DEPLOYMENT_NAME in "${DEPLOYMENTS[@]}"; do
    if kubectl -n $NAMESPACE get deployment $DEPLOYMENT_NAME &> /dev/null; then
        echo -e "${YELLOW}Deleting existing deployment: $DEPLOYMENT_NAME...${NC}"
        if ! kubectl -n $NAMESPACE delete deployment $DEPLOYMENT_NAME --wait=true; then
            echo -e "${RED}WARNING: Failed to delete $DEPLOYMENT_NAME completely. Continuing...${NC}"
        fi
    fi
done

# Cleanup Admin Secret (để đảm bảo token được tạo mới nếu cần)
if kubectl -n $NAMESPACE get secret $TOKEN_SECRET_NAME &> /dev/null; then
    echo -e "${YELLOW}Deleting existing admin Secret: $TOKEN_SECRET_NAME...${NC}"
    kubectl -n $NAMESPACE delete secret $TOKEN_SECRET_NAME
fi

# -----------------------------------------------------------------------------
# PART 2: APPLY DASHBOARD AND SERVICE ACCOUNT CONFIGURATION
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 2. Applying Dashboard and Service Account manifests...${NC}"

# Apply Dashboard (Deployment and Service)
echo -e "${YELLOW}Applying Dashboard manifest ($DASHBOARD_YAML)...${NC}"
kubectl apply -f $DASHBOARD_YAML

# Apply ServiceAccount (SA, Secret, RoleBinding)
echo -e "${YELLOW}Applying Admin ServiceAccount manifest ($SA_YAML)...${NC}"
kubectl apply -f $SA_YAML

# -----------------------------------------------------------------------------
# PART 3: VERIFICATION AND TOKEN RETRIEVAL
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}## 3. Waiting for Pods and Retrieving Admin Token...${NC}"

# Wait for all Dashboard pods to be ready
echo -e "${YELLOW}Waiting for Dashboard pods to be ready (timeout 180s)...${NC}"
# Lấy nhãn của Pod Server (thay vì label cũ là app.kubernetes.io/component=server)
kubectl -n $NAMESPACE wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard --timeout=180s

# Lấy Token từ Secret đã tạo thủ công (dashboard-admin-secret)
echo -e "${YELLOW}Retrieving token from Secret: $TOKEN_SECRET_NAME...${NC}"
ADMIN_TOKEN=$(kubectl -n $NAMESPACE get secret $TOKEN_SECRET_NAME -o jsonpath="{.data.token}" | base64 -d 2>/dev/null)

if [ -z "$ADMIN_TOKEN" ]; then
    echo -e "${RED}FATAL: Could not retrieve the admin token from $TOKEN_SECRET_NAME. Check Secret status.${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# PART 4: DISPLAY ACCESS INFORMATION
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}--- ✅ Kubernetes Dashboard Setup Complete ---${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}Dashboard URL (Access via proxy on Master/Control Plane):${NC}"
echo "http://127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/services/https:$DASHBOARD_DEPLOYMENT:/proxy/"
echo -e "${YELLOW}Admin Login Token (Copy this value to login):${NC}"
echo -e "${GREEN}$ADMIN_TOKEN${NC}"
echo -e "${BLUE}================================================================${NC}"

echo -e "\n${YELLOW}Press ENTER to finish the script (Token has been displayed).${NC}"
read