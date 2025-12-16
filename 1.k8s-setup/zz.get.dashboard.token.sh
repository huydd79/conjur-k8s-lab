#!/bin/bash

# Define ANSI color codes
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color (Reset)

TOKEN=$(kubectl -n kubernetes-dashboard get secret dashboard-admin-secret -o jsonpath="{.data.token}" | base64 -d)
echo -e "${YELLOW}$TOKEN${NC}"
