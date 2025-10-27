@echo off
setlocal enabledelayedexpansion
REM ################################################################################
REM #                     MediaStack WSL Service Manager                          #
REM #                           Windows Batch Script                               #
REM ################################################################################

REM Use the directory where this batch file is located
set "SERVICE_DIR=%~dp0"

REM Remove trailing backslash if present
if "%SERVICE_DIR:~-1%"=="\" set "SERVICE_DIR=%SERVICE_DIR:~0,-1%"

if not exist "%SERVICE_DIR%\wsl-ubuntu-monitoring.exe" (
    echo [ERROR] WSL Ubuntu Monitoring service not found!
    echo Expected location: %SERVICE_DIR%\wsl-ubuntu-monitoring.exe
    echo Please run install-wsl-service.bat first
    pause
    exit /b 1
)

echo WSL Ubuntu Monitoring Service Manager
echo ==============================
echo.
echo 1. Start Service
echo 2. Stop Service  
echo 3. Restart Service
echo 4. Service Status
echo 5. View Logs
echo 6. Uninstall Service
echo 7. Exit
echo.
set /p choice="Select option (1-7): "

cd /d "%SERVICE_DIR%"

if "%choice%"=="1" (
    echo Starting WSL Ubuntu Monitoring service...
    wsl-ubuntu-monitoring.exe start
    if %errorLevel% == 0 (
        echo [OK] Service started successfully
    ) else (
        echo [ERROR] Failed to start service
    )
) else if "%choice%"=="2" (
    echo Stopping WSL Ubuntu Monitoring service...
    wsl-ubuntu-monitoring.exe stop
    if %errorLevel% == 0 (
        echo [OK] Service stopped successfully
    ) else (
        echo [ERROR] Failed to stop service
    )
) else if "%choice%"=="3" (
    echo Restarting WSL Ubuntu Monitoring service...
    wsl-ubuntu-monitoring.exe restart
    if %errorLevel% == 0 (
        echo [OK] Service restarted successfully
    ) else (
        echo [ERROR] Failed to restart service
    )
) else if "%choice%"=="4" (
    echo Checking service status...
    wsl-ubuntu-monitoring.exe status
) else if "%choice%"=="5" (
    echo Opening log file...
    if exist "wsl-ubuntu-monitoring.out.log" (
        type wsl-ubuntu-monitoring.out.log
    ) else (
        echo No log file found
    )
) else if "%choice%"=="6" (
    echo [WARNING] This will completely remove the WSL Ubuntu Monitoring service
    set /p confirm="Are you sure? (y/N): "
    if /i "%confirm%"=="y" (
        echo Stopping service...
        wsl-ubuntu-monitoring.exe stop >nul 2>&1
        echo Uninstalling service...
        wsl-ubuntu-monitoring.exe uninstall
        if %errorLevel% == 0 (
            echo [OK] Service uninstalled successfully
        ) else (
            echo [ERROR] Failed to uninstall service
        )
    ) else (
        echo Cancelled
    )
) else if "%choice%"=="7" (
    exit /b 0
) else (
    echo Invalid choice
)

echo.
pause