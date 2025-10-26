#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Stop Script
##
##  This script stops all MediaStack services
##
##  Usage: ./stop-stack.sh
##
###########################################################################
###########################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}MediaStack Stop${NC}"
echo "================="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Change to parent directory where docker-compose files are located
cd "$(dirname "$SCRIPT_DIR")"

# Check if docker-compose.env exists
if [[ ! -f "docker-compose.env" ]]; then
    echo -e "${RED}✗ docker-compose.env file not found!${NC}"
    echo "Please make sure the environment file exists in the same directory as this script."
    exit 1
fi

echo -e "${YELLOW}Stopping all MediaStack services...${NC}"
echo ""

# Stop all services
for file in docker-compose-*.yaml; do
    if [[ -f "$file" ]]; then
        echo -e "${YELLOW}Stopping services in $file...${NC}"
        sudo docker compose --file "$file" --env-file docker-compose.env down
    fi
done

echo ""
echo -e "${GREEN}✓ All MediaStack services stopped!${NC}"

# Show remaining containers (if any)
echo ""
echo -e "${BLUE}Remaining containers:${NC}"
sudo docker ps