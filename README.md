# MediaStack Project - Enhanced Management System

> **Original Project:** This project is based on the [MediaStack Project](https://github.com/geekau/mediastack) by **geekau**. All credit for the core MediaStack architecture, Docker configurations, and application integrations goes to the original author.
> 
> See the original project on [Reddit for MediaStack](https://www.reddit.com/r/MediaStack/)

## Enhanced Features Overview

This enhanced version adds a **comprehensive management system** to the original MediaStack project with:

- **🎯 Unified Management Interface** - Single script for all operations
- **🏥 Advanced Health Monitoring** - Real HTTP health checks with dynamic port detection
- **🎛️ Selective Service Control** - Whitelist-based service management
- **📁 Organized Project Structure** - Clean separation of scripts, compose files, and data
- **🔄 Smart Container Orchestration** - Intelligent dependency handling (Gluetun-first)
- **✅ Code Quality Assurance** - Shellcheck-compliant scripts with proper error handling
- **🎨 Enhanced User Experience** - Colored output, progress indicators, and detailed logging

## Network Architecture - Full Download VPN Configuration

This enhanced management system is specifically designed for the **"Full Download VPN"** configuration from the original MediaStack project. This setup routes all network traffic from Docker containers through the Gluetun VPN container for maximum privacy and security.

<center>

``` mermaid
flowchart TD
  subgraph DockerNet["Full Download VPN"]
    Gluetun
    Jellyfin
    Plex
    Jellyseerr
    Prowlarr
    Radarr
    Readarr
    Sonarr
    Mylar
    Whisparr
    Bazarr
    Lidarr
    Tdarr
    Huntarr
    SABnzbd
    qBittorrent
    Label@{ label: "<div style=\"color:\"><span style=\"color:\">IP Subnet: 172.28.10.0/24</span></div>" }
    NIC["Network Adapter"]
  end

  Jellyfin     ---- Gluetun
  Plex         ---  Gluetun
  Jellyseerr   ---- Gluetun
  Prowlarr     ---  Gluetun
  Radarr       ---- Gluetun
  Readarr      ---  Gluetun
  Sonarr       ---- Gluetun
  Mylar        ---  Gluetun
  Whisparr     ---- Gluetun
  Bazarr       ---  Gluetun
  Lidarr       ---- Gluetun
  Tdarr        ---  Gluetun
  Huntarr      ---- Gluetun
  SABnzbd      ---  Gluetun
  qBittorrent  ---- Gluetun
  Gluetun      ==> NIC
  NIC          ==> Gateway
  Gateway      ==> VPN
  Gateway["Home Gateway"]
  VPN{"VPN Server<br>Anchor Point"}

  style Gluetun      stroke:#2962FF
  style Jellyfin     stroke:#2962FF
  style Plex         stroke:#2962FF
  style Jellyseerr   stroke:#2962FF
  style Prowlarr     stroke:#2962FF
  style Radarr       stroke:#2962FF
  style Readarr      stroke:#2962FF
  style Sonarr       stroke:#2962FF
  style Mylar        stroke:#2962FF
  style Whisparr     stroke:#2962FF
  style Bazarr       stroke:#2962FF
  style Lidarr       stroke:#2962FF
  style Tdarr        stroke:#2962FF
  style Huntarr      stroke:#2962FF
  style SABnzbd      stroke:#2962FF
  style qBittorrent  stroke:#2962FF
  style Label        stroke:none
  style NIC          stroke:green,    stroke-width:2px
  style Gateway      stroke:green,    stroke-width:2px
  style VPN          stroke:green,    stroke-width:2px
```

</center>

> **Key Architecture Benefits:**
> - **Maximum Privacy:** All container traffic routed through VPN encryption
> - **Intelligent Management:** Our scripts handle Gluetun dependency automatically
> - **Network Security:** VPN failure stops all container traffic (fail-safe design)
> - **Centralized Control:** Single VPN connection protects entire media stack

**For complete documentation** on VPN configurations, network architecture, and advanced features, visit the **[Original MediaStack Repository](https://github.com/geekau/mediastack)**.

## What Applications Are Provided In MediaStack  

Welcome to the MediaStack project! MediaStack is your ultimate solution for managing and streaming media collections with applications like Jellyfin and Plex. Using Docker, MediaStack containerises these media servers alongside *ARR applications (Radarr, Sonarr, Lidarr, etc.) for seamless media automation and management.

**Complete application list and original documentation available in the [Original Project README](README1.md)**

## Enhanced Directory Structure

```
/mnt/d/MediaStack/AppData/
├── data/                       # 📁 All container data (gitignored)
│   ├── gluetun/               # Container configurations and data
│   ├── radarr/                # (All service data folders)
│   ├── sonarr/
│   ├── jellyfin/
│   └── [20+ other services]/
├── compose/                    # 🐳 Docker Compose files
│   ├── docker-compose-gluetun.yaml
│   ├── docker-compose-radarr.yaml
│   ├── docker-compose-sonarr.yaml
│   └── [20+ other services].yaml
├── scripts/                    # 🛠️ Enhanced management scripts
│   ├── mediastack.sh          # ⭐ UNIFIED management script (all functionality)
│   ├── setup-directories.sh   # Automated directory setup
│   ├── pull-images.sh         # Docker image management
│   ├── start-stack.sh         # Intelligent service startup
│   ├── stop-stack.sh          # Graceful service shutdown
│   ├── update-stack.sh        # Update all services
│   ├── logs.sh                # Enhanced log viewing
│   └── status.sh              # Comprehensive status checking
├── mediastack.sh              # 🚀 Convenience launcher (main entry point)
├── docker-compose.env         # Environment configuration
├── services.whitelist         # 🎛️ Service selection configuration
└── .gitignore                 # Excludes data/ and sensitive configs
```

## Enhanced Management System Usage

### Unified Command Interface

The enhanced MediaStack provides a single entry point for all operations:

```bash
# Main management interface (recommended)
./mediastack.sh [command] [service]
```

### Core Commands

#### **Initial Setup**
```bash
./mediastack.sh setup           # Create directory structure automatically
./mediastack.sh pull            # Download all Docker images
./mediastack.sh start-all       # Start all services (Gluetun first)
```

#### **Daily Operations**
```bash
./mediastack.sh status          # Show container status with health checks
./mediastack.sh health          # Comprehensive health check with HTTP testing
./mediastack.sh list            # List all available services
./mediastack.sh logs [service]  # View logs for specific service
```

#### **Service Management**
```bash
# Individual service control
./mediastack.sh start [service]    # Start specific service
./mediastack.sh stop [service]     # Stop specific service  
./mediastack.sh restart [service]  # Restart specific service

# Bulk operations
./mediastack.sh start-all          # Start all services (intelligent ordering)
./mediastack.sh stop-all           # Stop all running services
./mediastack.sh restart-all        # Full restart (remove + recreate)
./mediastack.sh remove-all         # Stop and remove all containers
```

#### **Advanced Features**
```bash
./mediastack.sh update          # Update all services to latest images
./mediastack.sh whitelist       # Manage selective service control
./mediastack.sh help            # Show detailed command help
```

### Whitelist-Based Service Management

The enhanced system includes **selective service management** via `services.whitelist`:

```bash
# Enable whitelist mode
echo "prowlarr radarr sonarr jellyfin gluetun" > services.whitelist

# Only whitelisted services will be affected by:
./mediastack.sh start-all       # Starts only whitelisted services
./mediastack.sh restart-all     # Restarts only whitelisted services
```

**Note:** Individual service commands (`start [service]`, `stop [service]`) work on ALL services regardless of whitelist.

## Enhanced Features

### 🎯 **Unified Management System**
- **Single Entry Point:** All operations through one script (`./mediastack.sh`)
- **Comprehensive Commands:** Setup, management, monitoring, and maintenance
- **Intelligent Orchestration:** Smart dependency handling (Gluetun-first startup)

### 🏥 **Advanced Health Monitoring**
- **Real HTTP Health Checks:** Tests actual web service availability (not just ports)
- **Dynamic Port Detection:** Automatically reads ports from `docker-compose.env`
- **Comprehensive Status:** Container status + HTTP accessibility in one view
- **Health Command:** Dedicated health check with detailed reporting

### 🎛️ **Selective Service Control (Whitelist System)**
- **Service Selection:** Control which services are affected by bulk operations
- **Whitelist Configuration:** Simple file-based service selection (`services.whitelist`)
- **Flexible Management:** Individual services always accessible, bulk ops respect whitelist
- **Easy Configuration:** Add/remove services from automated management

### 📁 **Clean Project Organization**  
- **Separated Concerns:** Scripts, compose files, and data in dedicated folders
- **Git-Safe Structure:** Container data and configs excluded from version control
- **Automated Setup:** Directory structure created automatically
- **Environment-Driven:** All paths configurable via `docker-compose.env`

### 🔄 **Smart Container Orchestration**
- **Dependency Awareness:** Gluetun always starts first (VPN network priority)
- **Graceful Operations:** Proper start/stop sequences with error handling
- **Container-Aware Logic:** Works with actual running containers, not just compose files
- **Data Preservation:** Volumes and configurations persist across operations

### ✅ **Code Quality & Reliability**
- **Shellcheck Compliant:** All scripts pass static analysis
- **Proper Error Handling:** Robust error checking with `set -euo pipefail`
- **Quoted Variables:** Protection against path/space issues
- **Exit Code Management:** Proper error propagation (`|| exit 1` on critical commands)

### 🎨 **Enhanced User Experience**
- **Colored Output:** Easy-to-read status messages and progress indicators
- **Detailed Logging:** Comprehensive feedback for all operations
- **Help System:** Built-in documentation with `./mediastack.sh help`
- **Progress Feedback:** Clear indication of what the system is doing

## Implementation Details

### **Whitelist System**
The `services.whitelist` file controls which services are affected by bulk operations:

```bash
# Create whitelist with essential services
echo "gluetun prowlarr radarr sonarr jellyfin" > services.whitelist

# Bulk operations now only affect these services:
./mediastack.sh start-all    # Only starts whitelisted services
./mediastack.sh restart-all  # Only restarts whitelisted services

# Individual commands work on ALL services:
./mediastack.sh start plex   # Works regardless of whitelist
```

### **Health Check System**
Enhanced health monitoring with real HTTP testing:

```bash
./mediastack.sh health
# Output example:
# ✅ gluetun: Running (VPN connected)
# ✅ prowlarr: Running + HTTP accessible (http://192.168.1.100:9696)
# ❌ radarr: Running but HTTP not accessible (port 7878)
# ⚠️  jellyfin: Container stopped
```

### **Directory Management**
Automated directory creation with proper permissions:

```bash
./mediastack.sh setup
# Creates complete folder structure from docker-compose.env
# Sets proper ownership and permissions
# Handles Windows line endings in environment files
```

### **Project Migration Benefits**
Advantages of the enhanced structure:

- **📁 Clean Organization:** Container data moved to `data/` folder (gitignored)
- **🔄 Environment-Driven:** All paths from `docker-compose.env` variables
- **🚫 Git Safety:** Sensitive data excluded from version control
- **🛡️ Data Persistence:** Configurations survive container operations
- **🌐 VPN Priority:** Gluetun dependency handling for network security
- **📍 Relocatable:** Easy path changes via environment configuration

## Original MediaStack Documentation

For complete details about MediaStack applications, VPN configurations, remote access setup, and advanced features, see the **[Original Project Documentation](README1.md)**.

The original documentation includes:
- **Complete Application List** - All 30+ Docker applications with descriptions
- **VPN Network Configurations** - Full/Mini/No VPN setups
- **Security Features** - Traefik, Authentik, CrowdSec integration
- **Remote Access** - Tailscale mesh networking setup
- **Filesystem Mapping** - Media and data storage configuration
- **Advanced Configuration** - Headscale, authentication, and monitoring setup

## Contributing to Enhanced Features

This enhanced management system builds upon the excellent foundation of the original MediaStack project. The modifications focus on:

1. **Operational Excellence** - Making day-to-day management easier
2. **Code Quality** - Ensuring robust, maintainable scripts  
3. **User Experience** - Providing clear feedback and intuitive commands
4. **Selective Control** - Allowing granular service management

All enhancements preserve the original MediaStack architecture and are designed to be non-intrusive additions that improve usability while maintaining full compatibility with the base system.

---

**Credits:** Original MediaStack project by **geekau** - [GitHub Repository](https://github.com/geekau/mediastack)