#!/bin/bash
# -----------------------------------------------------------------------------
# Kubernetes Dashboard Deployment & Token Retrieval Script
# Script: 04.setup.dashboard.sh
# -----------------------------------------------------------------------------

# Colors for output
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

# Configuration
DASHBOARD_YAML="yaml/kube-dashboard.yaml"
SA_YAML="yaml/dashboard-serviceaccount.yaml"
NAMESPACE="kubernetes-dashboard"
TOKEN_SECRET_NAME="dashboard-admin-secret"

echo -e "${GREEN}--- 📊 Initiating Kubernetes Dashboard Deployment ---${NC}"

# Check for manifest files
if [[ ! -f "$DASHBOARD_YAML" || ! -f "$SA_YAML" ]]; then
    echo -e "${RED}ERROR: Required YAML files missing in yaml/ directory.${NC}"
    exit 1
fi

# 1. Cleanup existing components for a clean installation
echo -e "\n${BLUE}## 1. Cleaning up existing resources...${NC}"
kubectl -n $NAMESPACE delete deployment kubernetes-dashboard dashboard-metrics-scraper --ignore-not-found
kubectl -n $NAMESPACE delete secret $TOKEN_SECRET_NAME --ignore-not-found

# 2. Apply Manifests
echo -e "\n${BLUE}## 2. Applying Dashboard and Service Account manifests...${NC}"
kubectl apply -f $DASHBOARD_YAML
kubectl apply -f $SA_YAML

# 3. Wait for Readiness
echo -e "\n${BLUE}## 3. Waiting for Dashboard Pods to become READY...${NC}"
# Short sleep to allow API server to register pods
sleep 5
if ! kubectl -n $NAMESPACE wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard --timeout=180s; then
    echo -e "${RED}ERROR: Timeout waiting for Dashboard pods. Check logs with 'kubectl describe'.${NC}"
    exit 1
fi

# 4. Token Retrieval
echo -e "\n${BLUE}## 4. Extracting Admin Token...${NC}"
ADMIN_TOKEN=$(kubectl -n $NAMESPACE get secret $TOKEN_SECRET_NAME -o jsonpath="{.data.token}" | base64 -d 2>/dev/null)

if [[ -z "$ADMIN_TOKEN" ]]; then
    echo -e "${RED}FATAL: Failed to retrieve token from secret $TOKEN_SECRET_NAME.${NC}"
    exit 1
fi

# 5. Success Message
echo -e "\n${GREEN}--- ✅ Deployment Successful ---${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}External Access (NodePort):${NC} https://$(hostname -I | awk '{print $1}'):30443"
echo -e "\n${YELLOW}Admin Login Token:${NC}"
echo -e "${GREEN}${ADMIN_TOKEN}${NC}"
echo -e "${BLUE}================================================================${NC}"

echo -e "\n${YELLOW}Press ENTER to exit.${NC}"
read
