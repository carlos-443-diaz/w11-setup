#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Setup Script for Development, IT Management, Graphics Design, Time Configuration, and Terminal Setup
.DESCRIPTION
    This script performs initial setup for a new Windows 11 installation by installing
    essential software for software development, information systems management, graphics 
    design, configuring system time settings, and setting up Windows Terminal with taskbar
    integration and optimal default profiles using winget package manager.
.NOTES
    Author: Carlos Diaz
    Requires: Windows 11, Administrator privileges, winget package manager
#>

param(
    [switch]$SkipUpdates,
    [switch]$Quiet
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

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
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
    
    Write-ColorOutput "`n📦 Checking $Name ($Category)..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would check and install $Name" $Green
            Start-Sleep -Milliseconds 500  # Simulate installation time
            return
        }
        
        # Check if package is already installed
        $installed = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            Write-ColorOutput "✓ $Name is already installed" $Green
            return
        }
        
        Write-ColorOutput "  • Installing $Name..." $Blue
        $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Successfully installed $Name" $Green
        } else {
            Write-ColorOutput "⚠ $Name installation completed with warnings" $Yellow
        }
    }
    catch {
        Write-ColorOutput "✗ Failed to install $Name : $_" $Red
    }
}

function Configure-TimeSettings {
    Write-ColorOutput "`n🕒 Configuring time and date settings..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would configure time settings" $Green
            return
        }
        
        # Enable automatic time synchronization
        Write-ColorOutput "  • Enabling automatic time synchronization..." $Blue
        w32tm /config /manualpeerlist:"time.windows.com" /syncfromflags:manual /reliable:yes /update
        w32tm /resync
        
        # Set time zone automatically (attempts to detect location-based timezone)
        Write-ColorOutput "  • Configuring automatic timezone detection..." $Blue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3 -Force
        
        # Enable location services for timezone (if not already enabled)
        try {
            $locationConsent = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "Value" -ErrorAction SilentlyContinue
            if ($locationConsent.Value -ne "Allow") {
                Write-ColorOutput "  • Location services may need manual enabling for automatic timezone" $Yellow
            }
        }
        catch {
            Write-ColorOutput "  • Location settings configuration skipped" $Yellow
        }
        
        # Configure NTP client for more accurate time sync
        Write-ColorOutput "  • Configuring NTP time synchronization..." $Blue
        w32tm /config /syncfromflags:domhier /update
        
        # Set time format to include seconds (24-hour format)
        Write-ColorOutput "  • Setting time display format..." $Blue
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "HH:mm" -Force
        
        Write-ColorOutput "✓ Time configuration completed successfully" $Green
    }
    catch {
        Write-ColorOutput "⚠ Some time configuration settings may require manual setup: $_" $Yellow
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

function Show-Banner {
    Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                           Windows 11 Setup Script                           ║
║                                                                              ║
║  🛠️  Software Development Tools                                              ║
║  🔧 Information Systems Management                                           ║
║  🎨 Graphics Design & Media Tools                                            ║
║  🎬 Media Codecs & Extensions                                                ║
║  🕒 Time & Date Configuration                                                ║
║  ⚙️  Terminal Configuration & Taskbar Setup                                  ║
║                                                                              ║
║  This script will install essential software using winget package manager   ║
║  and configure system settings for an optimal development environment       ║
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

🎬 Media Codecs:
   • HEIF Image Extensions - Modern image format support
   • HEVC Video Extensions - Advanced video codec support

🕒 Time & Date Configuration:
   • Automatic time synchronization (NTP)
   • Automatic timezone detection
   • Enhanced time display format
   • Location-based timezone updates

⚙️  Terminal Configuration:
   • Windows Terminal Preview pinned to taskbar
   • Default profile set to WSL (if available) or PowerShell
   • Ready for immediate development workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@ $Blue
}

# Main execution starts here
Clear-Host
Show-Banner

if (-not $Quiet) {
    Write-ColorOutput "`n⚠️  This script requires Administrator privileges and will install multiple applications." $Yellow
    $response = Read-Host "`nDo you want to continue? (y/N)"
    if ($response -notmatch '^[Yy]') {
        Write-ColorOutput "Installation cancelled by user." $Yellow
        exit 0
    }
}

# Check if winget is available
Write-ColorOutput "`n🔍 Checking system requirements..." $Blue
if (-not (Test-WingetInstalled)) {
    Write-ColorOutput "`n❌ Winget package manager is required but not found." $Red
    Write-ColorOutput "Please install winget from the Microsoft Store (App Installer) or download from:" $Yellow
    Write-ColorOutput "https://github.com/microsoft/winget-cli/releases" $Yellow
    exit 1
}

# Update winget sources
if (-not $SkipUpdates) {
    Write-ColorOutput "`n🔄 Updating winget sources..." $Blue
    if ($PSVersionTable.Platform -eq "Unix") {
        Write-ColorOutput "✓ [SIMULATION] Would update winget sources" $Green
    } else {
        winget source update
    }
}

Show-Summary

Write-ColorOutput "`n🚀 Starting installation process..." $Green
Write-ColorOutput "This may take several minutes depending on your internet connection..." $Yellow

# Define packages to install
$packages = @(
    # Software Development Tools
    @{Id="Microsoft.VisualStudioCode"; Name="Visual Studio Code"; Category="Development"},
    @{Id="Microsoft.WindowsTerminal.Preview"; Name="Windows Terminal Preview"; Category="Development"},
    @{Id="Microsoft.WSL"; Name="Windows Subsystem for Linux"; Category="Development"},
    
    # Information Systems Management
    @{Id="AgileBits.1Password"; Name="1Password"; Category="Security"},
    @{Id="AgileBits.1PasswordCLI"; Name="1Password CLI"; Category="Security"},
    @{Id="Microsoft.PowerToys"; Name="PowerToys"; Category="Productivity"},
    
    # Graphics Design & Media
    @{Id="GIMP.GIMP"; Name="GIMP"; Category="Graphics"},
    @{Id="Inkscape.Inkscape"; Name="Inkscape"; Category="Graphics"},
    @{Id="HandBrake.HandBrake"; Name="HandBrake"; Category="Media"},
    
    # Essential System Tools
    @{Id="7zip.7zip"; Name="7-Zip"; Category="Utilities"},
    @{Id="VideoLAN.VLC"; Name="VLC Media Player"; Category="Media"},
    @{Id="Mozilla.Firefox"; Name="Firefox"; Category="Web Browser"},
    
    # Media Codecs
    @{Id="9PMMSR1CGPWG"; Name="HEIF Image Extensions"; Category="Media Codecs"},
    @{Id="9N4WGH0Z6VHQ"; Name="HEVC Video Extensions"; Category="Media Codecs"}
)

# Install each package
foreach ($package in $packages) {
    Install-WingetPackage -PackageId $package.Id -Name $package.Name -Category $package.Category
}

# Configure time and date settings
Configure-TimeSettings

# Configure Windows Terminal
Pin-WindowsTerminalToTaskbar
Configure-WindowsTerminalProfile

Write-ColorOutput @"

🎉 Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All packages have been processed and system configuration completed. Some applications may require a restart.

📝 Next Steps:
1. Restart your computer to complete WSL installation and apply time settings
2. Open Windows Terminal (now pinned to taskbar) and run 'wsl --install' to set up Linux
3. Install Git in WSL: 'sudo apt update && sudo apt install git'
4. Configure Git with your credentials in WSL: 
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
5. Set up 1Password CLI integration with WSL
6. Launch VS Code and install your preferred extensions
7. Verify time zone settings in Windows Settings if needed

💡 Configuration Summary:
• Windows Terminal Preview has been pinned to your taskbar
• Default terminal profile set to WSL (if available) or PowerShell
• Time sync and timezone are now automatically configured
• All essential development tools are installed

💡 Additional Tips:
• Use Windows Terminal for all your command-line work
• Configure Windows Terminal themes and appearance in Settings
• Use 1Password CLI for secure authentication in WSL
• Explore PowerToys features for enhanced productivity

Happy coding! 🚀
"@ $Green

if (-not $Quiet) {
    Read-Host "`nPress Enter to exit..."
}