#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Setup Script for Development, IT Management, and Graphics Design
.DESCRIPTION
    This script performs initial setup for a new Windows 11 installation by installing
    essential software for software development, information systems management, and 
    graphics design using winget package manager.
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
    
    Write-ColorOutput "`n📦 Installing $Name ($Category)..." $Blue
    
    try {
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-ColorOutput "✓ [SIMULATION] Would install $Name" $Green
            Start-Sleep -Milliseconds 500  # Simulate installation time
            return
        }
        
        $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✓ Successfully installed $Name" $Green
        } else {
            Write-ColorOutput "⚠ $Name may already be installed or installation completed with warnings" $Yellow
        }
    }
    catch {
        Write-ColorOutput "✗ Failed to install $Name : $_" $Red
    }
}

function Show-Banner {
    Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                           Windows 11 Setup Script                           ║
║                                                                              ║
║  🛠️  Software Development Tools                                              ║
║  🔧 Information Systems Management                                           ║
║  🎨 Graphics Design Software                                                 ║
║                                                                              ║
║  This script will install essential software using winget package manager   ║
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
   • Git - Version control system
   • Windows Subsystem for Linux (WSL) - Linux environment

🔧 Information Systems Management:
   • 1Password - Password manager and security
   • PowerToys - Windows utilities and productivity tools

🎨 Graphics Design:
   • GIMP - Advanced image editing
   • Inkscape - Vector graphics editor
   • Paint.NET - Lightweight image editor

💻 System Tools:
   • 7-Zip - File archiver
   • VLC Media Player - Media player
   • Firefox - Web browser

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
    @{Id="Git.Git"; Name="Git"; Category="Development"},
    @{Id="Microsoft.WSL"; Name="Windows Subsystem for Linux"; Category="Development"},
    
    # Information Systems Management
    @{Id="AgileBits.1Password"; Name="1Password"; Category="Security"},
    @{Id="Microsoft.PowerToys"; Name="PowerToys"; Category="Productivity"},
    
    # Graphics Design
    @{Id="GIMP.GIMP"; Name="GIMP"; Category="Graphics"},
    @{Id="Inkscape.Inkscape"; Name="Inkscape"; Category="Graphics"},
    @{Id="dotPDN.PaintDotNet"; Name="Paint.NET"; Category="Graphics"},
    
    # Essential System Tools
    @{Id="7zip.7zip"; Name="7-Zip"; Category="Utilities"},
    @{Id="VideoLAN.VLC"; Name="VLC Media Player"; Category="Media"},
    @{Id="Mozilla.Firefox"; Name="Firefox"; Category="Web Browser"}
)

# Install each package
foreach ($package in $packages) {
    Install-WingetPackage -PackageId $package.Id -Name $package.Name -Category $package.Category
}

Write-ColorOutput @"

🎉 Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All packages have been processed. Some applications may require a restart.

📝 Next Steps:
1. Restart your computer to complete WSL installation
2. Open Windows Terminal and run 'wsl --install' to set up Linux
3. Configure Git with your credentials: 
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
4. Launch VS Code and install your preferred extensions
5. Set up 1Password and import your vault

💡 Tips:
• Pin frequently used applications to your taskbar
• Configure Windows Terminal as your default terminal
• Explore PowerToys features for enhanced productivity

Happy coding! 🚀
"@ $Green

if (-not $Quiet) {
    Read-Host "`nPress Enter to exit..."
}