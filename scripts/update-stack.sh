#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Update Script
##
##  This script updates all Docker images and recreates containers
##  Based on the MediaStack Guide
##
##  Usage: ./update-stack.sh
##
###########################################################################
###########################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}MediaStack Update${NC}"
echo "=================="

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

echo -e "${YELLOW}Updating MediaStack: Pulling latest images and recreating containers...${NC}"
echo ""

# Download all of the Docker images needed for each YAML file
echo -e "${BLUE}Step 1: Pulling latest Docker images...${NC}"
for file in compose/docker-compose-*.yaml; do
    if [[ -f "$file" ]]; then
        echo -e "${YELLOW}Pulling Docker image for $file...${NC}"
        sudo docker compose --file "$file" --env-file docker-compose.env pull
    fi
done

echo ""
echo -e "${BLUE}Step 2: Recreating containers...${NC}"

# Start Gluetun container first, then start all other MediaStack containers
echo -e "${GREEN}Starting Gluetun first (required for network setup)...${NC}"
if [[ -f "compose/docker-compose-gluetun.yaml" ]]; then
    sudo docker compose --file compose/docker-compose-gluetun.yaml --env-file docker-compose.env up -d --force-recreate
    echo ""
fi

# Recreate all other containers
for file in compose/docker-compose-*.yaml; do
    if [[ "$file" != "compose/docker-compose-gluetun.yaml" && -f "$file" ]]; then
        echo -e "${YELLOW}Recreating Docker container for $file...${NC}"
        sudo docker compose --file "$file" --env-file docker-compose.env up -d --force-recreate
    fi
done

echo ""
echo -e "${GREEN}✓ MediaStack update complete!${NC}"
echo ""
echo -e "${BLUE}Service Status:${NC}"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo -e "${YELLOW}Update complete! All services have been updated with the latest images.${NC}"