#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Setup Script for Development, IT Management, Graphics Design, Time Configuration, and Desktop Customization, and Terminal Setup
.DESCRIPTION
    This script performs initial setup for a new Windows 11 installation by installing
    essential software for software development, information systems management, graphics 
    design, configuring system time settings, and customizing desktop and taskbar 
    preferences using winget package manager.
.PARAMETER SkipUpdates
    Skip updating winget sources before installation
.PARAMETER Quiet
    Suppress interactive prompts and run with minimal output
.PARAMETER Force
    Force installation without any user prompts (combines with Quiet for fully automated execution)
.PARAMETER WSLDistro
    Specify the WSL Linux distribution to install (default: Ubuntu)
.NOTES
    Author: Carlos Diaz
    Requires: Windows 11, Administrator privileges, winget package manager
#>

param(
    [switch]$SkipUpdates,
    [switch]$Quiet,
    [switch]$Force,
    [string]$WSLDistro = "Ubuntu"
)

# Set execution policy and error handling
if ($PSVersionTable.Platform -ne "Unix") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}
$ErrorActionPreference = "Continue"

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"
$White = "White"

# Error logging setup
$LogFile = "$env:TEMP\w11-setup-log.txt"
$ErrorLog = "$env:TEMP\w11-setup-errors.txt"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logMessage -ErrorAction SilentlyContinue
    
    # Also write errors to separate error log
    if ($Level -eq "ERROR" -or $Level -eq "WARNING") {
        Add-Content -Path $ErrorLog -Value $logMessage -ErrorAction SilentlyContinue
    }
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
    
    # Also write to log file
    $level = switch ($Color) {
        $Red { "ERROR" }
        $Yellow { "WARNING" }
        $Green { "SUCCESS" }
        default { "INFO" }
    }
    Write-Log -Message $Message -Level $level
}

function Test-WingetInstalled {
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "⚠ Running on non-Windows platform - winget simulation mode" $Yellow
            return $true
        }
        $wingetVersion = winget --version
        Write-ColorOutput "✓ Winget is installed: $wingetVersion" $Green
        return $true
    }
    catch {
        Write-ColorOutput "✗ Winget is not installed or not accessible" $Red
        return $false
    }
}

function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$Name,
        [string]$Category
    )
    
    if (-not $Force -and -not $Quiet) {
        Write-ColorOutput "`n📦 Checking $Name ($Category)..." $Blue
    }
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would check and install $Name" $Green
            Start-Sleep -Milliseconds 500  # Simulate installation time
            return
        }
        
        # Check if package is already installed
        $installed = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            if (-not $Force) {
                Write-ColorOutput "✓ $Name is already installed" $Green
            }
            return
        }
        
        if (-not $Force -and -not $Quiet) {
            Write-ColorOutput "  • Installing $Name..." $Blue
        }
        
        # Use additional flags for quieter installation
        $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1
        if ($LASTEXITCODE -eq 0) {
            if (-not $Force) {
                Write-ColorOutput "✓ Successfully installed $Name" $Green
            }
            Write-Log -Message "Successfully installed $Name (ID: $PackageId)" -Level "SUCCESS"
        } else {
            if (-not $Force) {
                Write-ColorOutput "⚠ $Name installation completed with warnings" $Yellow
                Write-ColorOutput "  See log file for details: $ErrorLog" $Yellow
            }
            Write-Log -Message "Installation of $Name (ID: $PackageId) completed with exit code $LASTEXITCODE. Output: $result" -Level "WARNING"
        }
    }
    catch {
        if (-not $Force) {
            Write-ColorOutput "✗ Failed to install $Name : $_" $Red
            Write-ColorOutput "  See log file for details: $ErrorLog" $Yellow
        }
        Write-Log -Message "Failed to install $Name (ID: $PackageId): $_" -Level "ERROR"
    }
}

function Get-WSLDistroChoice {
    if ($Force -or $Quiet) {
        return $WSLDistro
    }
    
    Write-ColorOutput "`n🐧 WSL Linux Distribution Selection" $Blue
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" $Blue
    
    $availableDistros = @(
        @{Name="Ubuntu"; Description="Ubuntu - Most popular, great for beginners"},
        @{Name="Ubuntu-22.04"; Description="Ubuntu 22.04 LTS - Long-term support version"},
        @{Name="Ubuntu-20.04"; Description="Ubuntu 20.04 LTS - Older LTS version"},
        @{Name="Debian"; Description="Debian - Stable and lightweight"},
        @{Name="kali-linux"; Description="Kali Linux - Security and penetration testing"},
        @{Name="openSUSE-Leap-15.5"; Description="openSUSE Leap - Enterprise-ready"},
        @{Name="Alpine"; Description="Alpine Linux - Minimal and security-focused"}
    )
    
    Write-ColorOutput "`nAvailable Linux distributions:" $Yellow
    for ($i = 0; $i -lt $availableDistros.Count; $i++) {
        $number = $i + 1
        $distro = $availableDistros[$i]
        Write-ColorOutput "  $number. $($distro.Description)" $White
    }
    
    Write-ColorOutput "`nDefault: Ubuntu (recommended for most users)" $Green
    $choice = Read-Host "`nEnter your choice (1-$($availableDistros.Count)) or press Enter for default"
    
    if ([string]::IsNullOrWhiteSpace($choice)) {
        return "Ubuntu"
    }
    
    if ($choice -match '^\d+$') {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $availableDistros.Count) {
            return $availableDistros[$index].Name
        }
    }
    
    Write-ColorOutput "Invalid selection. Using default: Ubuntu" $Yellow
    return "Ubuntu"
}

function Configure-TimeSettings {
    if (-not $Force) {
        Write-ColorOutput "`n🕒 Configuring time and date settings..." $Blue
    }
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            if (-not $Force) {
                Write-ColorOutput "✓ [SIMULATION] Would configure time settings" $Green
            }
            return
        }
        
        # Enable automatic time synchronization
        if (-not $Force) {
            Write-ColorOutput "  • Enabling automatic time synchronization..." $Blue
        }
        w32tm /config /manualpeerlist:"time.windows.com" /syncfromflags:manual /reliable:yes /update
        w32tm /resync
        
        # Set time zone automatically (attempts to detect location-based timezone)
        if (-not $Force) {
            Write-ColorOutput "  • Configuring automatic timezone detection..." $Blue
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3 -Force
        
        # Enable location services for timezone (if not already enabled)
        try {
            $locationConsent = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "Value" -ErrorAction SilentlyContinue
            if ($locationConsent.Value -ne "Allow") {
                if (-not $Force) {
                    Write-ColorOutput "  • Location services may need manual enabling for automatic timezone" $Yellow
                }
            }
        }
        catch {
            if (-not $Force) {
                Write-ColorOutput "  • Location settings configuration skipped" $Yellow
            }
        }
        
        # Configure NTP client for more accurate time sync
        if (-not $Force) {
            Write-ColorOutput "  • Configuring NTP time synchronization..." $Blue
        }
        w32tm /config /syncfromflags:domhier /update
        
        # Set time format to include seconds (24-hour format)
        if (-not $Force) {
            Write-ColorOutput "  • Setting time display format..." $Blue
        }
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "HH:mm" -Force
        
        if (-not $Force) {
            Write-ColorOutput "✓ Time configuration completed successfully" $Green
        }
    }
    catch {
        if (-not $Force) {
            Write-ColorOutput "⚠ Some time configuration settings may require manual setup: $_" $Yellow
        }
    }
}

function Test-WSLInstalled {
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            # For simulation, assume WSL is available
            return $true
        }
        
        # Check if WSL is enabled
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
        if ($wslFeature -and $wslFeature.State -eq "Enabled") {
            # Check if any WSL distributions are installed
            $wslList = wsl --list --quiet 2>$null
            if ($LASTEXITCODE -eq 0 -and $wslList) {
                return $true
            }
        }
        return $false
    }
    catch {
        return $false
    }
}

function Install-WSLDistribution {
    param(
        [string]$DistroName
    )
    
    if (-not $Force) {
        Write-ColorOutput "`n🐧 Installing WSL distribution: $DistroName..." $Blue
    }
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            if (-not $Force) {
                Write-ColorOutput "✓ [SIMULATION] Would install WSL distribution: $DistroName" $Green
            }
            return
        }
        
        # Check if WSL is installed
        $wslVersion = wsl --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            if (-not $Force) {
                Write-ColorOutput "⚠ WSL is not yet available. A system restart may be required." $Yellow
                Write-ColorOutput "  After restart, run: wsl --install -d $DistroName" $Yellow
            }
            Write-Log -Message "WSL not available yet, restart required. Distribution: $DistroName" -Level "WARNING"
            return
        }
        
        # Check if the distribution is already installed
        $installedDistros = wsl --list --quiet 2>$null
        if ($LASTEXITCODE -eq 0 -and $installedDistros -match $DistroName) {
            if (-not $Force) {
                Write-ColorOutput "✓ $DistroName is already installed" $Green
            }
            Write-Log -Message "WSL distribution $DistroName is already installed" -Level "INFO"
            return
        }
        
        # Install the distribution
        if (-not $Force) {
            Write-ColorOutput "  • Installing $DistroName distribution..." $Blue
            Write-ColorOutput "  • This may take several minutes..." $Yellow
        }
        
        # Run wsl --install with the specific distro and capture output
        $installOutput = wsl --install -d $DistroName 2>&1
        $exitCode = $LASTEXITCODE
        
        Write-Log -Message "WSL install command for $DistroName completed with exit code: $exitCode. Output: $installOutput" -Level "INFO"
        
        if ($exitCode -eq 0) {
            if (-not $Force) {
                Write-ColorOutput "✓ Successfully installed $DistroName" $Green
            }
            Write-Log -Message "Successfully installed WSL distribution: $DistroName" -Level "SUCCESS"
        } else {
            if (-not $Force) {
                Write-ColorOutput "⚠ $DistroName installation may require additional steps or a restart" $Yellow
                Write-ColorOutput "  After restart, you can complete setup by running: wsl --install -d $DistroName" $Yellow
                Write-ColorOutput "  See log file for details: $ErrorLog" $Yellow
            }
            Write-Log -Message "WSL distribution $DistroName installation completed with warnings. Exit code: $exitCode. Output: $installOutput" -Level "WARNING"
        }
    }
    catch {
        if (-not $Force) {
            Write-ColorOutput "⚠ WSL distribution installation encountered an issue: $_" $Yellow
            Write-ColorOutput "  After restart, run: wsl --install -d $DistroName" $Yellow
            Write-ColorOutput "  See log file for details: $ErrorLog" $Yellow
        }
        Write-Log -Message "WSL distribution $DistroName installation error: $_" -Level "ERROR"
    }
}

function Pin-WindowsTerminalToTaskbar {
    Write-ColorOutput "`n📌 Pinning Windows Terminal Preview to taskbar..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would pin Windows Terminal Preview to taskbar" $Green
            return
        }
        
        # Find Windows Terminal Preview executable
        $terminalPath = Get-ChildItem -Path "${env:ProgramFiles}\WindowsApps" -Filter "Microsoft.WindowsTerminalPreview*" -Directory | 
                       Select-Object -First 1 -ExpandProperty FullName
        
        if ($terminalPath) {
            $terminalExe = Join-Path $terminalPath "wt.exe"
            if (Test-Path $terminalExe) {
                # Use PowerShell COM objects to pin to taskbar
                Write-ColorOutput "  • Adding Windows Terminal Preview to taskbar..." $Blue
                $shell = New-Object -ComObject Shell.Application
                $folder = $shell.Namespace((Split-Path $terminalExe))
                $item = $folder.ParseName((Split-Path $terminalExe -Leaf))
                $verb = $item.Verbs() | Where-Object { $_.Name -match "taskbar|pin" }
                if ($verb) {
                    $verb.DoIt()
                    Write-ColorOutput "✓ Windows Terminal Preview pinned to taskbar" $Green
                } else {
                    Write-ColorOutput "⚠ Could not find pin to taskbar option" $Yellow
                }
            } else {
                Write-ColorOutput "⚠ Windows Terminal Preview executable not found" $Yellow
            }
        } else {
            Write-ColorOutput "⚠ Windows Terminal Preview installation path not found" $Yellow
        }
    }
    catch {
        Write-ColorOutput "⚠ Failed to pin Windows Terminal Preview to taskbar: $_" $Yellow
    }
}

function Configure-WindowsTerminalProfile {
    Write-ColorOutput "`n⚙️ Configuring Windows Terminal default profile..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would configure Windows Terminal default profile" $Green
            return
        }
        
        # Find Windows Terminal settings path
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
        
        # Check if WSL is available
        $wslAvailable = Test-WSLInstalled
        
        if (Test-Path $settingsPath) {
            Write-ColorOutput "  • Found existing Windows Terminal settings" $Blue
            
            # Read current settings
            $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
            
            if ($wslAvailable) {
                Write-ColorOutput "  • Setting WSL as default profile..." $Blue
                # Look for WSL profile in the profiles list
                $wslProfile = $settings.profiles.list | Where-Object { $_.source -eq "Windows.Terminal.Wsl" -or $_.name -match "Ubuntu|WSL" } | Select-Object -First 1
                if ($wslProfile) {
                    $settings.defaultProfile = $wslProfile.guid
                    Write-ColorOutput "✓ Set WSL profile as default" $Green
                } else {
                    Write-ColorOutput "⚠ WSL profile not found, keeping current default" $Yellow
                }
            } else {
                Write-ColorOutput "  • WSL not available, setting PowerShell as default..." $Blue
                $psProfile = $settings.profiles.list | Where-Object { $_.name -match "PowerShell" -and $_.name -notmatch "ISE" } | Select-Object -First 1
                if ($psProfile) {
                    $settings.defaultProfile = $psProfile.guid
                    Write-ColorOutput "✓ Set PowerShell profile as default" $Green
                } else {
                    Write-ColorOutput "⚠ PowerShell profile not found, keeping current default" $Yellow
                }
            }
            
            # Save updated settings
            $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
            Write-ColorOutput "✓ Windows Terminal configuration updated" $Green
        } else {
            Write-ColorOutput "⚠ Windows Terminal settings file not found - will be created on first run" $Yellow
        }
    }
    catch {
        Write-ColorOutput "⚠ Failed to configure Windows Terminal profile: $_" $Yellow
    }
}

function Configure-DesktopSettings {
    Write-ColorOutput "`n🎨 Configuring desktop and theme settings..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would configure desktop settings" $Green
            return
        }
        
        # Set Windows to dark theme
        Write-ColorOutput "  • Setting Windows theme to dark mode..." $Blue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Force
        
        # Set taskbar to dark theme 
        Write-ColorOutput "  • Configuring taskbar for dark theme..." $Blue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0 -Force
        
        Write-ColorOutput "✓ Desktop theme configuration completed successfully" $Green
    }
    catch {
        Write-ColorOutput "⚠ Some desktop theme settings may require manual setup: $_" $Yellow
    }
}

function Configure-TaskbarSettings {
    Write-ColorOutput "`n📊 Configuring taskbar settings..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would configure taskbar settings" $Green
            return
        }
        
        # Create taskbar registry path if it doesn't exist
        $taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        if (!(Test-Path $taskbarPath)) {
            New-Item -Path $taskbarPath -Force | Out-Null
        }
        
        # Hide search box from taskbar
        Write-ColorOutput "  • Hiding search box from taskbar..." $Blue
        Set-ItemProperty -Path $taskbarPath -Name "SearchboxTaskbarMode" -Value 0 -Force
        
        # Hide task view button
        Write-ColorOutput "  • Hiding task view button..." $Blue
        Set-ItemProperty -Path $taskbarPath -Name "ShowTaskViewButton" -Value 0 -Force
        
        # Hide Copilot button (Windows 11 22H2+)
        Write-ColorOutput "  • Hiding Copilot button..." $Blue
        Set-ItemProperty -Path $taskbarPath -Name "ShowCopilotButton" -Value 0 -Force -ErrorAction SilentlyContinue
        
        # Enable taskbar auto-hide
        Write-ColorOutput "  • Enabling taskbar auto-hide..." $Blue
        Set-ItemProperty -Path $taskbarPath -Name "TaskbarAutoHideInDesktopMode" -Value 1 -Force
        
        # Remove Windows Store from taskbar (remove from pinned items)
        Write-ColorOutput "  • Configuring taskbar pinned items..." $Blue
        $pinnedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
        if (Test-Path $pinnedPath) {
            # This removes the default pinned items including Store and other unwanted apps
            Remove-ItemProperty -Path $pinnedPath -Name "Favorites" -ErrorAction SilentlyContinue
        }
        
        Write-ColorOutput "✓ Taskbar configuration completed successfully" $Green
    }
    catch {
        Write-ColorOutput "⚠ Some taskbar settings may require manual setup: $_" $Yellow
    }
}

function Configure-WidgetSettings {
    Write-ColorOutput "`n🏗️ Configuring widget settings..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would configure widget settings" $Green
            return
        }
        
        # Disable widgets on taskbar
        Write-ColorOutput "  • Configuring taskbar widgets..." $Blue
        $widgetPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        
        # Create the path if it doesn't exist
        if (!(Test-Path $widgetPath)) {
            New-Item -Path $widgetPath -Force | Out-Null
        }
        
        # Try to set TaskbarDa with better error handling
        try {
            Set-ItemProperty -Path $widgetPath -Name "TaskbarDa" -Value 0 -Force -ErrorAction Stop
        }
        catch {
            Write-ColorOutput "  • Taskbar widget setting may require manual configuration" $Yellow
        }
        
        # Configure weather widget to not show sports
        Write-ColorOutput "  • Configuring widget content preferences..." $Blue
        $weatherPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
        if (!(Test-Path $weatherPath)) {
            New-Item -Path $weatherPath -Force | Out-Null
        }
        
        # Disable sports content in widgets
        Set-ItemProperty -Path $weatherPath -Name "IsFeedsAvailable" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $weatherPath -Name "ShellFeedsTaskbarViewMode" -Value 2 -Force -ErrorAction SilentlyContinue
        
        Write-ColorOutput "✓ Widget configuration completed successfully" $Green
    }
    catch {
        Write-ColorOutput "⚠ Some widget settings may require manual setup: $_" $Yellow
    }
}

function Show-Banner {
    Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                           Windows 11 Setup Script                            ║
║                                                                              ║
║  🛠️  Software Development Tools                                              ║
║  🔧 Information Systems Management                                           ║
║  🎨 Graphics Design & Media Tools                                            ║
║  🎬 Media Codecs & Extensions                                                ║
║  🕒 Time & Date Configuration                                                ║
║  🖥️  Desktop & Taskbar Customization                                         ║
║  ⚙️  Terminal Configuration                                                  ║
║                                                                              ║
║  This script will install essential software using winget package manager    ║
║  and configure system settings for an optimal development environment        ║
╚══════════════════════════════════════════════════════════════════════════════╝
"@ $Blue
}

function Show-Summary {
    Write-ColorOutput @"

📋 Installation Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛠️  Software Development:
   • Visual Studio Code - Modern code editor
   • Windows Terminal Preview - Enhanced terminal experience (pinned to taskbar)
   • Windows Subsystem for Linux (WSL) - Linux environment with Git
   • Claude Code - AI-powered coding assistant

🔧 Information Systems Management:
   • 1Password - Password manager and security
   • 1Password CLI - Command-line interface for WSL integration
   • PowerToys - Windows utilities and productivity tools

🎨 Graphics Design & Media:
   • GIMP - Advanced image editing
   • Inkscape - Vector graphics editor
   • HandBrake - Video transcoder and converter

💻 System Tools:
   • 7-Zip - File archiver
   • VLC Media Player - Media player
   • Firefox - Web browser
   • Zen Browser - Privacy-focused web browser

🎬 Media Codecs:
   • HEIF Image Extensions - Modern image format support
   • HEVC Video Extensions - Advanced video codec support

🕒 Time & Date Configuration:
   • Automatic time synchronization (NTP)
   • Automatic timezone detection
   • Enhanced time display format
   • Location-based timezone updates

🖥️  Desktop & Taskbar Customization:
   • Windows dark theme configuration
   • Taskbar auto-hide enabled
   • Search box, Task View, and Copilot removed from taskbar
   • Widget sports content disabled
   • Clean taskbar layout for productivity

⚙️  Terminal Configuration:
   • Windows Terminal Preview pinned to taskbar
   • Default profile set to WSL (if available) or PowerShell
   • Ready for immediate development workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@ $Blue
}

# Main execution starts here
Clear-Host

# Initialize log files
if ($PSVersionTable.Platform -ne "Unix") {
    # Clear previous logs
    if (Test-Path $LogFile) { Remove-Item $LogFile -Force -ErrorAction SilentlyContinue }
    if (Test-Path $ErrorLog) { Remove-Item $ErrorLog -Force -ErrorAction SilentlyContinue }
    
    # Create new logs
    "Windows 11 Setup Script - Execution started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $LogFile -Encoding UTF8
    "Windows 11 Setup Script - Error Log" | Out-File -FilePath $ErrorLog -Encoding UTF8
    Write-Log -Message "Script execution started" -Level "INFO"
}

if (-not $Force) {
    Show-Banner
    if ($PSVersionTable.Platform -ne "Unix") {
        Write-ColorOutput "`n📝 Logs will be saved to:" $Blue
        Write-ColorOutput "   Full log: $LogFile" $White
        Write-ColorOutput "   Error log: $ErrorLog" $White
    }
}

# Check admin privileges upfront
if ($PSVersionTable.Platform -ne "Unix") {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = (New-Object Security.Principal.WindowsPrincipal($currentUser)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-ColorOutput "`n❌ This script requires Administrator privileges." $Red
        Write-ColorOutput "Please right-click PowerShell and select 'Run as Administrator', then try again." $Yellow
        exit 1
    }
}

if (-not $Quiet -and -not $Force) {
    Write-ColorOutput "`n⚠️  This script will install multiple applications and requires Administrator privileges." $Yellow
    $response = Read-Host "`nDo you want to continue? (y/N)"
    if ($response -notmatch '^[Yy]') {
        Write-ColorOutput "Installation cancelled by user." $Yellow
        exit 0
    }
}

# Check if winget is available
if (-not $Force) {
    Write-ColorOutput "`n🔍 Checking system requirements..." $Blue
}
if (-not (Test-WingetInstalled)) {
    Write-ColorOutput "`n❌ Winget package manager is required but not found." $Red
    Write-ColorOutput "Please install winget from the Microsoft Store (App Installer) or download from:" $Yellow
    Write-ColorOutput "https://github.com/microsoft/winget-cli/releases" $Yellow
    exit 1
}

# Update winget sources
if (-not $SkipUpdates) {
    if (-not $Force) {
        Write-ColorOutput "`n🔄 Updating winget sources..." $Blue
    }
    if ($PSVersionTable.Platform -eq "Unix") {
        if (-not $Force) {
            Write-ColorOutput "✓ [SIMULATION] Would update winget sources" $Green
        }
    } else {
        winget source update
    }
}

# Get WSL distro choice
$selectedDistro = Get-WSLDistroChoice

if (-not $Force) {
    Show-Summary
    Write-ColorOutput "`n🚀 Starting installation process..." $Green
    Write-ColorOutput "This may take several minutes depending on your internet connection..." $Yellow
    if ($selectedDistro -ne "Ubuntu") {
        Write-ColorOutput "Selected WSL distribution: $selectedDistro" $Blue
    }
}

# Define packages to install
$packages = @(
    # Software Development Tools
    @{Id="Microsoft.VisualStudioCode"; Name="Visual Studio Code"; Category="Development"},
    @{Id="Microsoft.WindowsTerminal.Preview"; Name="Windows Terminal Preview"; Category="Development"},
    @{Id="Microsoft.WSL"; Name="Windows Subsystem for Linux"; Category="Development"},
    @{Id="Anthropic.ClaudeCode"; Name="Claude Code"; Category="AI Assistant"},
    
    # Information Systems Management
    @{Id="AgileBits.1Password"; Name="1Password"; Category="Security"},
    @{Id="AgileBits.1PasswordCLI"; Name="1Password CLI"; Category="Security"},
    @{Id="Microsoft.PowerToys"; Name="PowerToys"; Category="Productivity"},
    
    # Graphics Design & Media
    @{Id="9PNSJCLXDZ0V"; Name="GIMP"; Category="Graphics"},
    @{Id="Inkscape.Inkscape"; Name="Inkscape"; Category="Graphics"},
    @{Id="HandBrake.HandBrake"; Name="HandBrake"; Category="Media"},
    
    # Essential System Tools
    @{Id="7zip.7zip"; Name="7-Zip"; Category="Utilities"},
    @{Id="VideoLAN.VLC"; Name="VLC Media Player"; Category="Media"},
    @{Id="Mozilla.Firefox"; Name="Firefox"; Category="Web Browser"},
    @{Id="zen-team.zen-browser"; Name="Zen Browser"; Category="Web Browser"},
    
    # Media Codecs
    @{Id="9PMMSR1CGPWG"; Name="HEIF Image Extensions"; Category="Media Codecs"},
    @{Id="9N4WGH0Z6VHQ"; Name="HEVC Video Extensions"; Category="Media Codecs"}
)

# Install each package
foreach ($package in $packages) {
    Install-WingetPackage -PackageId $package.Id -Name $package.Name -Category $package.Category
}

# Install WSL distribution after WSL package is installed
Install-WSLDistribution -DistroName $selectedDistro

# Configure time and date settings
Configure-TimeSettings

# Configure desktop and theme settings
Configure-DesktopSettings

# Configure taskbar settings
Configure-TaskbarSettings

# Configure widget settings
Configure-WidgetSettings

# Configure Windows Terminal
Pin-WindowsTerminalToTaskbar
Configure-WindowsTerminalProfile

Write-ColorOutput @"

🎉 Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All packages have been processed and system configuration completed.

📝 Installation Logs:
   • Full log: $LogFile
   • Error log: $ErrorLog

⚠️  IMPORTANT: A system restart is REQUIRED to complete installation!
   • WSL installation requires a restart to finalize
   • System settings and configurations need restart to take effect
   • Several applications may not function properly until restart

📝 Next Steps:
1. 🔄 RESTART YOUR COMPUTER NOW (critical for WSL and system settings)
2. After restart, open Windows Terminal to verify $selectedDistro is installed
3. If WSL distro is not installed, run: wsl --install -d $selectedDistro
4. Install Git in WSL: 'sudo apt update && sudo apt install git' (for Ubuntu/Debian)
5. Configure Git with your credentials in WSL: 
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
6. Set up 1Password CLI integration with WSL
7. Launch VS Code and Claude Code to start coding
8. Verify time zone settings in Windows Settings if needed
9. Check that dark theme and taskbar settings are applied correctly

💡 Tips:
• Claude Code is now installed for AI-powered assistance
• Pin frequently used applications to your taskbar (now auto-hiding)
• Configure Windows Terminal as your default terminal
• Use 1Password CLI for secure authentication in WSL
• Explore PowerToys features for enhanced productivity
• Time sync and timezone should now be automatically configured
• Desktop is now configured with dark theme and clean taskbar layout
• Taskbar will auto-hide - move mouse to bottom of screen to reveal

💡 Configuration Summary:
• Windows Terminal Preview has been pinned to your taskbar
• Default terminal profile set to WSL (if available) or PowerShell
• Time sync and timezone are now automatically configured
• All essential development tools including Claude Code are installed
• WSL distribution installation initiated

💡 Additional Configuration:
• Import Windows Terminal settings if you have a backup
• Configure PowerToys keyboard shortcuts and utilities
• Set up 1Password browser extensions in Firefox and Zen Browser

🔄 Remember: Restart your computer to complete the installation!

Happy coding! 🚀
"@ $Green

if (-not $Quiet -and -not $Force) {
    Read-Host "`nPress Enter to exit..."
}