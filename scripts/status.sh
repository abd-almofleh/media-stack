#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Status Checker
##
##  This script shows the status of all MediaStack services
##
##  Usage: ./status.sh
##
###########################################################################
###########################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}MediaStack Service Status${NC}"
echo "==========================="
echo ""

# Show running containers
echo -e "${GREEN}Running Containers:${NC}"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo -e "${YELLOW}Container Resource Usage:${NC}"
sudo docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo -e "${BLUE}Docker Network Information:${NC}"
sudo docker network ls | grep mediastack

echo ""
echo -e "${BLUE}Docker Volume Information:${NC}"
sudo docker volume ls | head -10