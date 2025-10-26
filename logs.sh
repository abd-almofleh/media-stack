#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Logs Viewer
##
##  This script shows logs for all MediaStack services
##
##  Usage: ./logs.sh [service_name]
##  Example: ./logs.sh gluetun
##
###########################################################################
###########################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ $# -eq 1 ]]; then
    # Show logs for specific service
    echo -e "${BLUE}Showing logs for $1...${NC}"
    sudo docker logs -f "$1"
else
    # Show logs for all services
    echo -e "${BLUE}Showing logs for all MediaStack services...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
    echo ""
    sudo docker logs -f $(sudo docker ps --format "{{.Names}}" | tr '\n' ' ')
fi