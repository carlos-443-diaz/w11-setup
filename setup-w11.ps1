#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Setup Script for Development, IT Management, Graphics Design, and Time Configuration
.DESCRIPTION
    This script performs initial setup for a new Windows 11 installation by installing
    essential software for software development, information systems management, graphics 
    design, and configuring system time settings using winget package manager.
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
        $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
        if ($LASTEXITCODE -eq 0) {
            if (-not $Force) {
                Write-ColorOutput "✓ Successfully installed $Name" $Green
            }
        } else {
            if (-not $Force) {
                Write-ColorOutput "⚠ $Name installation completed with warnings" $Yellow
            }
        }
    }
    catch {
        if (-not $Force) {
            Write-ColorOutput "✗ Failed to install $Name : $_" $Red
        }
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

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@ $Blue
}

# Main execution starts here
Clear-Host

if (-not $Force) {
    Show-Banner
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

Write-ColorOutput @"

🎉 Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All packages have been processed and time settings configured. Some applications may require a restart.

📝 Next Steps:
1. Restart your computer to complete WSL installation and apply time settings
2. Open Windows Terminal and run 'wsl --install -d $selectedDistro' to set up $selectedDistro Linux
3. Install Git in WSL: 'sudo apt update && sudo apt install git' (for Ubuntu/Debian) or equivalent for your distro
4. Configure Git with your credentials in WSL: 
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
5. Set up 1Password CLI integration with WSL
6. Launch VS Code and install your preferred extensions
7. Verify time zone settings in Windows Settings if needed

💡 Tips:
• Pin frequently used applications to your taskbar
• Configure Windows Terminal as your default terminal
• Use 1Password CLI for secure authentication in WSL
• Explore PowerToys features for enhanced productivity
• Time sync and timezone should now be automatically configured

Happy coding! 🚀
"@ $Green

if (-not $Quiet -and -not $Force) {
    Read-Host "`nPress Enter to exit..."
}