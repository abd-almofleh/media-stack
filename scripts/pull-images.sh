#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Docker Images Pull Script
##
##  This script pulls all Docker images for MediaStack services
##  Based on the MediaStack Guide
##
##  Usage: ./pull-images.sh
##
###########################################################################
###########################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}MediaStack Docker Images Pull${NC}"
echo "====================================="

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

echo -e "${YELLOW}Pulling Docker images for all MediaStack services...${NC}"
echo ""

# Download all of the Docker images needed for each YAML file
for file in compose/docker-compose-*.yaml; do
    if [[ -f "$file" ]]; then
        echo -e "${BLUE}Pulling Docker image for $file...${NC}"
        if sudo docker compose --file "$file" --env-file docker-compose.env pull; then
            echo -e "${GREEN}✓ Successfully pulled images for $file${NC}"
        else
            echo -e "${RED}✗ Failed to pull images for $file${NC}"
        fi
        echo ""
    fi
done

echo -e "${GREEN}✓ Docker image pull complete!${NC}"
echo -e "${YELLOW}Next step:${NC}"
echo "Run ./start-stack.sh to start the MediaStack services"