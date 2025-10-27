@echo off
setlocal enabledelayedexpansion
REM ################################################################################
REM #                  MediaStack WSL Service Auto-Installer                      #
REM #                           Windows Batch Script                               #
REM ################################################################################

echo MediaStack WSL Service Auto-Installer
echo =====================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running with Administrator privileges
) else (
    echo [ERROR] This script must be run as Administrator
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Set paths - Use the directory where this batch file is located
set "SERVICE_DIR=%~dp0"
set "WINSW_URL=https://github.com/winsw/winsw/releases/latest/download/WinSW-x64.exe"

REM Remove trailing backslash if present
if "%SERVICE_DIR:~-1%"=="\" set "SERVICE_DIR=%SERVICE_DIR:~0,-1%"

echo [INFO] Service directory: %SERVICE_DIR%

echo.
echo [INFO] Setting up service directory...
if not exist "%SERVICE_DIR%" (
    mkdir "%SERVICE_DIR%"
    echo Created %SERVICE_DIR%
)

REM Check if WinSW executable exists
if not exist "%SERVICE_DIR%\wsl-ubuntu-monitoring.exe" (
    echo.
    echo [INFO] Downloading Windows Service Wrapper...
    echo From: %WINSW_URL%
    echo To: %SERVICE_DIR%\wsl-ubuntu-monitoring.exe
    
    REM Try to download using PowerShell
    powershell -Command "try { Invoke-WebRequest -Uri '%WINSW_URL%' -OutFile '%SERVICE_DIR%\wsl-ubuntu-monitoring.exe' -UseBasicParsing; Write-Host '[OK] Download completed successfully' } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }"
    
    if %errorLevel% neq 0 (
        echo.
        echo [ERROR] Automatic download failed. Please manually download:
        echo 1. Go to: https://github.com/winsw/winsw/releases
        echo 2. Download WinSW-x64.exe
        echo 3. Save as: %SERVICE_DIR%\wsl-ubuntu-monitoring.exe
        echo 4. Run this script again
        pause
        exit /b 1
    )
) else (
    echo [OK] Windows Service Wrapper already exists
)

REM Create XML configuration file
echo.
echo [INFO] Creating service configuration...
(
echo ^<service^>
echo   ^<id^>wsl-ubuntu-monitoring^</id^>
echo   ^<name^>WSL Ubuntu Monitoring Service^</name^>
echo   ^<description^>Monitors and maintains WSL Ubuntu instance for Docker operations. Ensures WSL stays active for container stacks and services.^</description^>
echo   ^<executable^>C:\Program Files\WSL\wsl.exe^</executable^>
echo   ^<startarguments^>-d ubuntu ^</startarguments^>
echo   ^<priority^>Normal^</priority^>
echo   ^<stoptimeout^>30 sec^</stoptimeout^>
echo   ^<stopparentprocessfirst^>true^</stopparentprocessfirst^>
echo   ^<startmode^>Automatic^</startmode^>
echo   ^<depend^>Eventlog^</depend^>
echo   ^<waithint^>30 sec^</waithint^>
echo   ^<sleeptime^>1 sec^</sleeptime^>
echo   ^<log mode="roll"^>
echo     ^<sizeThreshold^>10240^</sizeThreshold^>
echo     ^<keepFiles^>8^</keepFiles^>
echo   ^</log^>
echo ^</service^>
) > "%SERVICE_DIR%\wsl-ubuntu-monitoring.xml"

echo [OK] Created wsl-ubuntu-monitoring.xml
echo.
echo [INFO] Stopping existing service (if running)...
"%SERVICE_DIR%\wsl-ubuntu-monitoring.exe" stop >nul 2>&1

REM Uninstall existing service if it exists
echo [INFO] Removing existing service (if exists)...
"%SERVICE_DIR%\wsl-ubuntu-monitoring.exe" uninstall >nul 2>&1

REM Install the service
echo.
echo [INFO] Installing WSL Ubuntu Monitoring service...
cd /d "%SERVICE_DIR%"
wsl-ubuntu-monitoring.exe install

if %errorLevel% == 0 (
    echo [OK] Service installed successfully
) else (
    echo [ERROR] Service installation failed
    pause
    exit /b 1
)

REM Get current user for service configuration
echo.
echo [INFO] Configuring service to run with current user credentials...
echo.
echo [IMPORTANT] The service needs to run with your user account credentials.
echo [IMPORTANT] Your Windows account MUST have a password set for this to work.
echo.
set /p USERNAME="Enter your Windows username (or press Enter for %USERNAME%): "
if "%USERNAME%"=="" set "USERNAME=%USERNAME%"

echo.
echo [INFO] Setting service to run as user: %USERNAME%
echo.
echo [IMPORTANT] You will need to:
echo 1. Open Services (services.msc)
echo 2. Find "WSL Ubuntu Monitoring Service"
echo 3. Right-click - Properties - Log On tab
echo 4. Select "This account" and enter: %USERNAME%
echo 5. Enter your Windows password
echo 6. Click OK
echo.
set /p CONTINUE="Press Enter to continue with service startup, or Ctrl+C to stop here..."

REM Start the service
echo.
echo [INFO] Starting WSL Ubuntu Monitoring service...
wsl-ubuntu-monitoring.exe start

if %errorLevel% == 0 (
    echo [OK] Service started successfully
    echo.
    echo [SUCCESS] WSL Ubuntu Monitoring Service Setup Complete!
    echo.
    echo Service Details:
    echo - Name: WSL Ubuntu Monitoring Service
    echo - Status: Running
    echo - Startup: Automatic
    echo - Location: %SERVICE_DIR%
    echo.
    echo [INFO] To manage the service:
    echo - Start: %SERVICE_DIR%\wsl-ubuntu-monitoring.exe start
    echo - Stop:  %SERVICE_DIR%\wsl-ubuntu-monitoring.exe stop
    echo - Status: %SERVICE_DIR%\wsl-ubuntu-monitoring.exe status
    echo - Logs: %SERVICE_DIR%\wsl-ubuntu-monitoring.out.log
    echo.
    echo [INFO] Your Docker containers should now start automatically with Windows!
) else (
    echo [ERROR] Service startup failed
    echo.
    echo This might be because:
    echo 1. Your Windows account doesn't have a password
    echo 2. The service credentials aren't configured
    echo 3. WSL Ubuntu isn't properly installed
    echo.
    echo Please check the service configuration in Services (services.msc)
)

echo.
echo [INFO] Next Steps:
echo 1. Restart your computer to test automatic startup
echo 2. Check service status: %SERVICE_DIR%\wsl-ubuntu-monitoring.exe status
echo 3. View logs: %SERVICE_DIR%\wsl-ubuntu-monitoring.out.log
echo 4. Start your container stacks: cd to your project and run startup commands

pause