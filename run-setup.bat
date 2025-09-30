@echo off
:: Windows 11 Setup Script Launcher
:: This batch file will run the PowerShell script with administrator privileges

echo.
echo ========================================
echo    Windows 11 Setup Script Launcher
echo ========================================
echo.
echo This will install essential software for:
echo  - Software Development
echo  - Information Systems Management  
echo  - Graphics Design
echo.
echo Administrator privileges are required.
echo.
pause

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
    goto :run_script
) else (
    echo.
    echo ERROR: Administrator privileges required!
    echo Please right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:run_script
:: Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup-w11.ps1"

echo.
echo Script execution completed.
pause