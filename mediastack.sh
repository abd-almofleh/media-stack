#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Management Script
##
##  This script helps manage your complete media stack with Docker Compose
##
##  Usage:
##    ./mediastack.sh setup              - Create directories and setup environment
##    ./mediastack.sh pull               - Pull all Docker images
##    ./mediastack.sh start              - Start all services
##    ./mediastack.sh stop               - Stop all services
##    ./mediastack.sh restart            - Restart all services
##    ./mediastack.sh logs               - Show logs for all services
##    ./mediastack.sh status             - Show status of all services
##    ./mediastack.sh update             - Pull latest images and restart
##    ./mediastack.sh start <service>    - Start individual service
##    ./mediastack.sh stop <service>     - Stop individual service
##    ./mediastack.sh restart <service>  - Restart individual service
##    ./mediastack.sh logs <service>     - Show logs for individual service
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

# Function to check if docker-compose.env exists
check_env_file() {
    if [[ ! -f "docker-compose.env" ]]; then
        echo -e "${RED}Error: docker-compose.env file not found!${NC}"
        echo "Please make sure the environment file exists in the same directory as this script."
        exit 1
    fi
}

# Function to run docker compose with proper environment
run_compose() {
    docker compose --env-file docker-compose.env "$@"
}

case "$1" in
    setup)
        echo -e "${GREEN}Setting up MediaStack directories...${NC}"
        ./setup-directories.sh
        ;;
    pull)
        echo -e "${BLUE}Pulling Docker images...${NC}"
        ./pull-images.sh
        ;;
    start)
        if [[ -n "$2" ]]; then
            # Start individual service
            ./container.sh start "$2"
        else
            # Start all services
            echo -e "${GREEN}Starting MediaStack services...${NC}"
            ./start-stack.sh
        fi
        ;;
    stop)
        if [[ -n "$2" ]]; then
            # Stop individual service
            ./container.sh stop "$2"
        else
            # Stop all services
            echo -e "${YELLOW}Stopping MediaStack services...${NC}"
            ./stop-stack.sh
        fi
        ;;
    restart)
        if [[ -n "$2" ]]; then
            # Restart individual service
            ./container.sh restart "$2"
        else
            # Restart all services
            echo -e "${YELLOW}Restarting MediaStack services...${NC}"
            ./stop-stack.sh
            sleep 5
            ./start-stack.sh
        fi
        ;;
    logs)
        if [[ -n "$2" ]]; then
            # Show logs for individual service
            ./container.sh logs "$2"
        else
            # Show logs for all services
            echo -e "${BLUE}Showing logs for MediaStack services...${NC}"
            ./logs.sh
        fi
        ;;
    status)
        echo -e "${BLUE}MediaStack services status:${NC}"
        ./status.sh
        ;;
    update)
        echo -e "${BLUE}Updating MediaStack...${NC}"
        ./update-stack.sh
        ;;
    list)
        ./container.sh list
        ;;
    *)
        echo -e "${BLUE}MediaStack Management Script${NC}"
        echo ""
        echo "Usage: $0 {setup|pull|start|stop|restart|logs|status|update|list} [service_name]"
        echo ""
        echo -e "${GREEN}All Services Commands:${NC}"
        echo "  setup                  - Create directories and setup environment"
        echo "  pull                   - Pull all Docker images"
        echo "  start                  - Start all MediaStack services (in correct order)"
        echo "  stop                   - Stop all MediaStack services"
        echo "  restart                - Restart all MediaStack services"
        echo "  logs                   - Show logs for all services (Ctrl+C to exit)"
        echo "  status                 - Show status of all services"
        echo "  update                 - Pull latest images and restart services"
        echo "  list                   - List all available services"
        echo ""
        echo -e "${GREEN}Individual Service Commands:${NC}"
        echo "  start <service>        - Start individual service"
        echo "  stop <service>         - Stop individual service"
        echo "  restart <service>      - Restart individual service"
        echo "  logs <service>         - Show logs for individual service"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 start gluetun       - Start only Gluetun"
        echo "  $0 stop radarr         - Stop only Radarr"
        echo "  $0 logs jellyfin       - Show Jellyfin logs"
        echo "  $0 restart prowlarr    - Restart Prowlarr"
        echo ""
        echo -e "${YELLOW}First time setup:${NC}"
        echo "1. ./mediastack.sh setup"
        echo "2. ./mediastack.sh pull"
        echo "3. ./mediastack.sh start"
        echo ""
        exit 1
        ;;
esac