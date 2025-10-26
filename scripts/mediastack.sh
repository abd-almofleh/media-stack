#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Unified Management Script
##
##  This script provides complete MediaStack management functionality
##
##  Setup & Installation:
##    ./mediastack.sh setup              - Create directories and setup environment
##    ./mediastack.sh pull               - Pull all Docker images
##    ./mediastack.sh update             - Pull latest images and restart
##
##  Service Management:
##    ./mediastack.sh start              - Start all services (Gluetun first)
##    ./mediastack.sh stop               - Stop all services
##    ./mediastack.sh restart            - Restart all services
##    ./mediastack.sh start-all          - Start all services (Gluetun first)
##    ./mediastack.sh stop-all           - Stop running services (keep containers)
##    ./mediastack.sh restart-all        - Restart all services
##    ./mediastack.sh remove-all         - Stop and remove all containers
##
##  Individual Services:
##    ./mediastack.sh start <service>    - Start individual service
##    ./mediastack.sh stop <service>     - Stop individual service
##    ./mediastack.sh restart <service>  - Restart individual service
##    ./mediastack.sh logs <service>     - Show logs for individual service
##
##  Monitoring:
##    ./mediastack.sh logs               - Show logs for all services
##    ./mediastack.sh status             - Show status of all services
##    ./mediastack.sh list               - List all available services
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
# Change to parent directory where docker-compose files are located
cd "$(dirname "$SCRIPT_DIR")"

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

# Function to find the compose file for a service
find_compose_file() {
    local service_name=$1
    local compose_file=""
    
    # Check if it's a direct docker-compose file name
    if [[ -f "compose/docker-compose-${service_name}.yaml" ]]; then
        compose_file="compose/docker-compose-${service_name}.yaml"
    else
        # Search for the service in all compose files
        for file in compose/docker-compose-*.yaml; do
            if [[ -f "$file" ]]; then
                if grep -q "container_name: ${service_name}" "$file" 2>/dev/null; then
                    compose_file="$file"
                    break
                fi
            fi
        done
    fi
    
    echo "$compose_file"
}

# Function to list available services
list_services() {
    echo -e "${BLUE}Available services:${NC}"
    echo "==================="
    
    for file in compose/docker-compose-*.yaml; do
        if [[ -f "$file" ]]; then
            service=$(basename "$file" .yaml | sed 's/docker-compose-//')
            container_name=$(grep "container_name:" "$file" 2>/dev/null | head -1 | awk '{print $2}')
            if [[ -n "$container_name" ]]; then
                echo -e "${GREEN}$service${NC} (container: $container_name)"
            else
                echo -e "${YELLOW}$service${NC}"
            fi
        fi
    done
    
    echo ""
    echo -e "${BLUE}Running containers:${NC}"
    sudo docker ps --format "table {{.Names}}\t{{.Status}}"
}

# Function to start all services in correct order (Gluetun first)
start_all_services() {
    echo -e "${GREEN}Starting all MediaStack services...${NC}"
    echo -e "${YELLOW}Starting in correct order (Gluetun first)${NC}"
    echo ""
    
    # Start Gluetun first (required for network setup)
    if [[ -f "compose/docker-compose-gluetun.yaml" ]]; then
        echo -e "${BLUE}Starting Gluetun VPN (required first)...${NC}"
        sudo docker compose --file "compose/docker-compose-gluetun.yaml" --env-file docker-compose.env up -d
        echo ""
        sleep 3
    fi
    
    # Start all other services
    for file in compose/docker-compose-*.yaml; do
        if [[ "$file" != "compose/docker-compose-gluetun.yaml" && -f "$file" ]]; then
            service=$(basename "$file" .yaml | sed 's/docker-compose-//')
            echo -e "${BLUE}Starting $service...${NC}"
            sudo docker compose --file "$file" --env-file docker-compose.env up -d
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ All services started!${NC}"
}

# Function to stop all running services (without removing containers)
stop_all_services() {
    echo -e "${YELLOW}Stopping all running MediaStack services...${NC}"
    echo ""
    
    # Get list of running MediaStack containers
    local running_containers=$(sudo docker ps --format "{{.Names}}" | grep -E "(gluetun|bazarr|jellyfin|jellyseerr|lidarr|mylar|plex|portainer|prowlarr|qbittorrent|radarr|readarr|sabnzbd|sonarr|swag|tdarr|unpackerr|whisparr|flaresolverr|homarr|homepage|heimdall|ddns-updater|authelia|filebot)")
    
    if [[ -z "$running_containers" ]]; then
        echo -e "${BLUE}No MediaStack containers are currently running.${NC}"
        return
    fi
    
    # Stop each running container
    while IFS= read -r container; do
        if [[ -n "$container" ]]; then
            echo -e "${YELLOW}Stopping $container...${NC}"
            sudo docker stop "$container"
        fi
    done <<< "$running_containers"
    
    echo ""
    echo -e "${YELLOW}✓ All running services stopped!${NC}"
    echo -e "${BLUE}Containers are preserved and can be started again.${NC}"
}

# Function to remove all services (stop and remove containers)
remove_all_services() {
    echo -e "${RED}Removing all MediaStack services and containers...${NC}"
    echo -e "${YELLOW}This will stop and remove containers but preserve volumes/data.${NC}"
    echo ""
    
    # Get list of all MediaStack containers (running and stopped)
    local all_containers=$(sudo docker ps -a --format "{{.Names}}" | grep -E "(gluetun|bazarr|jellyfin|jellyseerr|lidarr|mylar|plex|portainer|prowlarr|qbittorrent|radarr|readarr|sabnzbd|sonarr|swag|tdarr|unpackerr|whisparr|flaresolverr|homarr|homepage|heimdall|ddns-updater|authelia|filebot)")
    
    if [[ -z "$all_containers" ]]; then
        echo -e "${BLUE}No MediaStack containers found.${NC}"
        return
    fi
    
    # Stop and remove each container
    while IFS= read -r container; do
        if [[ -n "$container" ]]; then
            echo -e "${RED}Removing $container...${NC}"
            # Stop container if running, then remove it
            sudo docker stop "$container" 2>/dev/null || true
            sudo docker rm "$container" 2>/dev/null || true
        fi
    done <<< "$all_containers"
    
    # Clean up the mediastack network if it exists and has no containers
    echo -e "${BLUE}Cleaning up mediastack network...${NC}"
    sudo docker network rm mediastack 2>/dev/null || true
    
    echo ""
    echo -e "${RED}✓ All services removed!${NC}"
    echo -e "${BLUE}Data volumes are preserved. Use start-all to recreate containers.${NC}"
}

# Function to restart all services
restart_all_services() {
    echo -e "${YELLOW}Restarting all MediaStack services...${NC}"
    
    # For restart, we need to fully recreate containers
    remove_all_services
    echo ""
    echo -e "${BLUE}Waiting 5 seconds before restart...${NC}"
    sleep 5
    start_all_services
}

# Handle commands that don't need service_name first
case "$1" in
    setup)
        echo -e "${GREEN}Setting up MediaStack directories...${NC}"
        "$SCRIPT_DIR/setup-directories.sh"
        exit 0
        ;;
    pull)
        echo -e "${BLUE}Pulling Docker images...${NC}"
        "$SCRIPT_DIR/pull-images.sh"
        exit 0
        ;;
    update)
        echo -e "${BLUE}Updating MediaStack...${NC}"
        "$SCRIPT_DIR/update-stack.sh"
        exit 0
        ;;
    list)
        list_services
        exit 0
        ;;
    start-all)
        check_env_file
        start_all_services
        exit 0
        ;;
    stop-all)
        check_env_file
        stop_all_services
        exit 0
        ;;
    restart-all)
        check_env_file
        restart_all_services
        exit 0
        ;;
    remove-all)
        check_env_file
        remove_all_services
        exit 0
        ;;
    status)
        echo -e "${BLUE}MediaStack services status:${NC}"
        "$SCRIPT_DIR/status.sh"
        exit 0
        ;;
esac

# Handle commands that may have individual service operations
command=$1
service_name=$2

case "$command" in
    start)
        check_env_file
        if [[ -n "$service_name" ]]; then
            # Start individual service
            compose_file=$(find_compose_file "$service_name")
            if [[ -z "$compose_file" ]]; then
                echo -e "${RED}✗ Service '$service_name' not found!${NC}"
                echo ""
                list_services
                exit 1
            fi
            echo -e "${GREEN}Starting service: $service_name${NC}"
            echo -e "${BLUE}Using file: $compose_file${NC}"
            if sudo docker compose --file "$compose_file" --env-file docker-compose.env up -d; then
                echo -e "${GREEN}✓ $service_name started successfully${NC}"
            else
                echo -e "${RED}✗ Failed to start $service_name${NC}"
            fi
        else
            # Start all services
            start_all_services
        fi
        ;;
    stop)
        check_env_file
        if [[ -n "$service_name" ]]; then
            # Stop individual service
            compose_file=$(find_compose_file "$service_name")
            if [[ -z "$compose_file" ]]; then
                echo -e "${RED}✗ Service '$service_name' not found!${NC}"
                echo ""
                list_services
                exit 1
            fi
            echo -e "${YELLOW}Stopping service: $service_name${NC}"
            echo -e "${BLUE}Container: $service_name${NC}"
            if sudo docker stop "$service_name" 2>/dev/null; then
                echo -e "${YELLOW}✓ $service_name stopped successfully${NC}"
                echo -e "${BLUE}Container preserved and can be restarted.${NC}"
            else
                echo -e "${RED}✗ Failed to stop $service_name (may not be running)${NC}"
            fi
        else
            # Stop all services (preserve containers)
            stop_all_services
        fi
        ;;
    restart)
        check_env_file
        if [[ -n "$service_name" ]]; then
            # Restart individual service
            compose_file=$(find_compose_file "$service_name")
            if [[ -z "$compose_file" ]]; then
                echo -e "${RED}✗ Service '$service_name' not found!${NC}"
                echo ""
                list_services
                exit 1
            fi
            echo -e "${YELLOW}Restarting service: $service_name${NC}"
            echo -e "${BLUE}Using file: $compose_file${NC}"
            sudo docker compose --file "$compose_file" --env-file docker-compose.env down
            sleep 2
            if sudo docker compose --file "$compose_file" --env-file docker-compose.env up -d; then
                echo -e "${GREEN}✓ $service_name restarted successfully${NC}"
            else
                echo -e "${RED}✗ Failed to restart $service_name${NC}"
            fi
        else
            # Restart all services
            restart_all_services
        fi
        ;;
    logs)
        if [[ -n "$service_name" ]]; then
            # Show logs for individual service
            echo -e "${BLUE}Showing logs for service: $service_name${NC}"
            echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
            echo ""
            # Try container name first, then service name
            if sudo docker logs -f "$service_name" 2>/dev/null; then
                :
            else
                compose_file=$(find_compose_file "$service_name")
                if [[ -n "$compose_file" ]]; then
                    sudo docker compose --file "$compose_file" --env-file docker-compose.env logs -f
                else
                    echo -e "${RED}✗ Service '$service_name' not found!${NC}"
                fi
            fi
        else
            # Show logs for all services
            echo -e "${BLUE}Showing logs for MediaStack services...${NC}"
            "$SCRIPT_DIR/logs.sh"
        fi
        ;;
    *)
        echo -e "${BLUE}MediaStack Unified Management Script${NC}"
        echo "======================================="
        echo ""
        echo "Usage: $0 <command> [service_name]"
        echo ""
        echo -e "${GREEN}Setup & Installation:${NC}"
        echo "  setup                  - Create directories and setup environment"
        echo "  pull                   - Pull all Docker images"
        echo "  update                 - Pull latest images and restart services"
        echo ""
        echo -e "${GREEN}Service Management:${NC}"
        echo "  start                  - Start all services (Gluetun first)"
        echo "  stop                   - Stop all running services (keep containers)"
        echo "  restart                - Restart all services"
        echo "  start-all              - Start all services (Gluetun first)"
        echo "  stop-all               - Stop all running services (keep containers)"
        echo "  restart-all            - Restart all services"
        echo "  remove-all             - Stop and remove all containers"
        echo ""
        echo -e "${GREEN}Individual Services:${NC}"
        echo "  start <service>        - Start individual service"
        echo "  stop <service>         - Stop individual service"
        echo "  restart <service>      - Restart individual service"
        echo "  logs <service>         - Show logs for individual service"
        echo ""
        echo -e "${GREEN}Monitoring:${NC}"
        echo "  logs                   - Show logs for all services (Ctrl+C to exit)"
        echo "  status                 - Show status of all services"
        echo "  list                   - List all available services"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 start gluetun       - Start only Gluetun"
        echo "  $0 stop-all            - Stop all running containers (preserve)"
        echo "  $0 remove-all          - Remove all containers"
        echo "  $0 logs jellyfin       - Show Jellyfin logs"
        echo "  $0 start-all           - Start all services"
        echo ""
        echo -e "${YELLOW}First time setup:${NC}"
        echo "1. $0 setup"
        echo "2. $0 pull"
        echo "3. $0 start"
        echo ""
        list_services
        exit 1
        ;;
esac