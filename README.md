# MediaStack Management Scripts

This directory contains a unified management system for your MediaStack Docker setup.

## Directory Structure

```
/mnt/d/MediaStack/AppData/
├── data/                       # 📁 All container data (gitignored)
│   ├── gluetun/               # Container configurations and data
│   ├── radarr/                # (All service data folders)
│   ├── sonarr/
│   └── ...
├── scripts/                    # All management scripts
│   ├── mediastack.sh          # ⭐ UNIFIED management script (all functionality)
│   ├── setup-directories.sh   # Directory setup
│   ├── pull-images.sh         # Docker image pulling
│   ├── start-stack.sh         # Start all services
│   ├── stop-stack.sh          # Stop all services
│   ├── update-stack.sh        # Update all services
│   ├── logs.sh                # View logs
│   └── status.sh              # Check status
├── mediastack.sh              # 🚀 Convenience launcher
├── docker-compose-*.yaml      # Individual service definitions
├── docker-compose.env         # Environment variables
└── .gitignore                 # Excludes data/ folder
```

## Usage

### From Main Directory (Recommended)

```bash
# Using convenience launcher
./mediastack.sh start-all       # Start all services
./mediastack.sh stop gluetun    # Stop individual service
./mediastack.sh list            # List all services
```

### From Scripts Directory

```bash
# Direct script access
./scripts/mediastack.sh start-all
./scripts/mediastack.sh list
```

## Quick Start

1. **First Time Setup:**
   ```bash
   ./mediastack.sh setup    # Create directories
   ./mediastack.sh pull     # Download images
   ./mediastack.sh start    # Start services
   ```

2. **Daily Operations:**
   ```bash
   ./mediastack.sh status         # Check status
   ./mediastack.sh list           # List services
   ./mediastack.sh logs jellyfin  # View specific logs
   ```

3. **Individual Container Management:**
   ```bash
   ./mediastack.sh start gluetun    # Start specific service
   ./mediastack.sh stop radarr      # Stop specific service
   ./mediastack.sh restart jellyfin # Restart specific service
   ```

4. **Bulk Operations:**
   ```bash
   ./mediastack.sh start-all    # Start all (Gluetun first)
   ./mediastack.sh stop-all     # Stop all running (preserve containers)
   ./mediastack.sh remove-all   # Remove all containers
   ./mediastack.sh restart-all  # Full restart
   ```

## Features

- **🎯 Unified Management:** Single script handles all operations
- **📁 Organized Structure:** All scripts in dedicated `scripts/` folder  
- **🚀 Convenience Launcher:** Use from main directory
- **🔄 Smart Ordering:** Gluetun always starts first
- **🎛️ Individual Control:** Manage single containers
- **📦 Bulk Operations:** Control all containers at once
- **💾 Data Preservation:** Scripts preserve volumes and configurations
- **🎨 Colored Output:** Easy to read status messages
- **🛑 Smart Stopping:** Choose between stop-all (preserve) or remove-all (cleanup)

## Notes

- **📁 Clean Organization:** Container data is now in `data/` folder (gitignored)
- **🔄 Automatic Paths:** All scripts and compose files use environment variables
- **🚫 Git Safe:** Container data folders are excluded from version control
- **🛡️ Data Preserved:** All container configurations persist across operations
- **🌐 Network Priority:** Gluetun always starts first to establish VPN network
- **📍 Flexible Paths:** Easy to relocate by updating `FOLDER_FOR_DATA` in `.env`