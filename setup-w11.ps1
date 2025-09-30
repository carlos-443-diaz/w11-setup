#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Setup Script for Development, IT Management, Graphics Design, Time Configuration, and Desktop Customization
.DESCRIPTION
    This script performs initial setup for a new Windows 11 installation by installing
    essential software for software development, information systems management, graphics 
    design, configuring system time settings, and customizing desktop and taskbar 
    preferences using winget package manager.
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
        Set-ItemProperty -Path $widgetPath -Name "TaskbarDa" -Value 0 -Force
        
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
║                           Windows 11 Setup Script                           ║
║                                                                              ║
║  🛠️  Software Development Tools                                              ║
║  🔧 Information Systems Management                                           ║
║  🎨 Graphics Design & Media Tools                                            ║
║  🎬 Media Codecs & Extensions                                                ║
║  🕒 Time & Date Configuration                                                ║
║  🖥️  Desktop & Taskbar Customization                                         ║
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
   • Windows Terminal Preview - Enhanced terminal experience
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

🖥️  Desktop & Taskbar Customization:
   • Windows dark theme configuration
   • Taskbar auto-hide enabled
   • Search box, Task View, and Copilot removed from taskbar
   • Widget sports content disabled
   • Clean taskbar layout for productivity

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

# Configure desktop and theme settings
Configure-DesktopSettings

# Configure taskbar settings
Configure-TaskbarSettings

# Configure widget settings
Configure-WidgetSettings

Write-ColorOutput @"

🎉 Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All packages have been processed and system settings configured. Some applications may require a restart.

📝 Next Steps:
1. Restart your computer to complete WSL installation and apply all settings
2. Open Windows Terminal and run 'wsl --install' to set up Linux
3. Install Git in WSL: 'sudo apt update && sudo apt install git'
4. Configure Git with your credentials in WSL: 
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
5. Set up 1Password CLI integration with WSL
6. Launch VS Code and install your preferred extensions
7. Verify time zone settings in Windows Settings if needed
8. Check that dark theme and taskbar settings are applied correctly

💡 Tips:
• Pin frequently used applications to your taskbar (now auto-hiding)
• Configure Windows Terminal as your default terminal
• Use 1Password CLI for secure authentication in WSL
• Explore PowerToys features for enhanced productivity
• Time sync and timezone should now be automatically configured
• Desktop is now configured with dark theme and clean taskbar layout
• Taskbar will auto-hide - move mouse to bottom of screen to reveal

Happy coding! 🚀
"@ $Green

if (-not $Quiet) {
    Read-Host "`nPress Enter to exit..."
}