#!/bin/bash

###########################################################################
###########################################################################
##
##  MediaStack Individual & Bulk Container Management
##
##  This script manages individual containers or all containers at once
##
##  Individual Usage: 
##    ./container.sh start <service_name>
##    ./container.sh stop <service_name>
##    ./container.sh restart <service_name>
##    ./container.sh logs <service_name>
##
##  Bulk Operations:
##    ./container.sh start-all
##    ./container.sh stop-all
##    ./container.sh restart-all
##    ./container.sh remove-all
##    ./container.sh list
##
##  Examples:
##    ./container.sh start gluetun
##    ./container.sh stop radarr
##    ./container.sh logs jellyfin
##    ./container.sh start-all
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
        echo -e "${RED}✗ docker-compose.env file not found!${NC}"
        echo "Please make sure the environment file exists in the same directory as this script."
        exit 1
    fi
}

# Function to find the compose file for a service
find_compose_file() {
    local service_name=$1
    local compose_file=""
    
    # Check if it's a direct docker-compose file name
    if [[ -f "docker-compose-${service_name}.yaml" ]]; then
        compose_file="docker-compose-${service_name}.yaml"
    else
        # Search for the service in all compose files
        for file in docker-compose-*.yaml; do
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
    
    for file in docker-compose-*.yaml; do
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
    if [[ -f "docker-compose-gluetun.yaml" ]]; then
        echo -e "${BLUE}Starting Gluetun VPN (required first)...${NC}"
        sudo docker compose --file "docker-compose-gluetun.yaml" --env-file docker-compose.env up -d
        echo ""
        sleep 3
    fi
    
    # Start all other services
    for file in docker-compose-*.yaml; do
        if [[ "$file" != "docker-compose-gluetun.yaml" && -f "$file" ]]; then
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
    
    for file in docker-compose-*.yaml; do
        if [[ -f "$file" ]]; then
            service=$(basename "$file" .yaml | sed 's/docker-compose-//')
            echo -e "${RED}Removing $service...${NC}"
            sudo docker compose --file "$file" --env-file docker-compose.env down
        fi
    done
    
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

# Main script logic
if [[ $# -lt 1 ]]; then
    echo -e "${BLUE}MediaStack Individual & Bulk Container Management${NC}"
    echo "================================================="
    echo ""
    echo "Usage: $0 <command> [service_name]"
    echo ""
    echo -e "${GREEN}Individual Commands:${NC}"
    echo "  start <service>   - Start a specific service"
    echo "  stop <service>    - Stop a specific service"
    echo "  restart <service> - Restart a specific service"
    echo "  logs <service>    - Show logs for a specific service"
    echo ""
    echo -e "${GREEN}Bulk Commands:${NC}"
    echo "  start-all         - Start all services (Gluetun first)"
    echo "  stop-all          - Stop running services (keep containers)"
    echo "  restart-all       - Restart all services"
    echo "  remove-all        - Stop and remove all containers"
    echo "  list              - List all available services"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 start gluetun"
    echo "  $0 stop radarr"
    echo "  $0 restart jellyfin"
    echo "  $0 logs prowlarr"
    echo "  $0 start-all"
    echo "  $0 stop-all"
    echo "  $0 remove-all"
    echo ""
    list_services
    exit 1
fi

command=$1
service_name=$2

# Handle bulk commands that don't need service_name
case "$command" in
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
esac

if [[ -z "$service_name" ]]; then
    echo -e "${RED}✗ Service name is required!${NC}"
    echo "Usage: $0 $command <service_name>"
    exit 1
fi

check_env_file

# Find the compose file for the service
compose_file=$(find_compose_file "$service_name")

if [[ -z "$compose_file" ]]; then
    echo -e "${RED}✗ Service '$service_name' not found!${NC}"
    echo ""
    list_services
    exit 1
fi

case "$command" in
    start)
        echo -e "${GREEN}Starting service: $service_name${NC}"
        echo -e "${BLUE}Using file: $compose_file${NC}"
        if sudo docker compose --file "$compose_file" --env-file docker-compose.env up -d; then
            echo -e "${GREEN}✓ $service_name started successfully${NC}"
        else
            echo -e "${RED}✗ Failed to start $service_name${NC}"
        fi
        ;;
    stop)
        echo -e "${YELLOW}Stopping service: $service_name${NC}"
        echo -e "${BLUE}Using file: $compose_file${NC}"
        if sudo docker compose --file "$compose_file" --env-file docker-compose.env down; then
            echo -e "${YELLOW}✓ $service_name stopped successfully${NC}"
        else
            echo -e "${RED}✗ Failed to stop $service_name${NC}"
        fi
        ;;
    restart)
        echo -e "${YELLOW}Restarting service: $service_name${NC}"
        echo -e "${BLUE}Using file: $compose_file${NC}"
        sudo docker compose --file "$compose_file" --env-file docker-compose.env down
        sleep 2
        if sudo docker compose --file "$compose_file" --env-file docker-compose.env up -d; then
            echo -e "${GREEN}✓ $service_name restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart $service_name${NC}"
        fi
        ;;
    logs)
        echo -e "${BLUE}Showing logs for service: $service_name${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        # Try container name first, then service name
        if sudo docker logs -f "$service_name" 2>/dev/null; then
            :
        else
            sudo docker compose --file "$compose_file" --env-file docker-compose.env logs -f
        fi
        ;;
    *)
        echo -e "${RED}✗ Unknown command: $command${NC}"
        echo "Available commands: start, stop, restart, logs, list, start-all, stop-all, restart-all, remove-all"
        exit 1
        ;;
esac