#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Setup Script for Development, IT Management, Graphics Design, and Time Configuration
.DESCRIPTION
    This script performs initial setup for a new Windows 11 installation by installing
    essential software for software development, information systems management, graphics 
    design, and configuring system time settings using winget package manager.
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

function Show-PackageSelection {
    param(
        [array]$Packages
    )
    
    Write-ColorOutput "`n📦 Package Selection:" $Blue
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" $Blue
    Write-ColorOutput "`nThe following packages will be installed:" $Yellow
    
    for ($i = 0; $i -lt $Packages.Length; $i++) {
        $package = $Packages[$i]
        $number = $i + 1
        Write-ColorOutput ("  {0,2}. {1} - {2} ({3})" -f $number, $package.Name, $package.Id, $package.Category) $White
    }
    
    Write-ColorOutput "`n💡 You can remove packages from the installation list by entering their numbers." $Blue
    Write-ColorOutput "   Example: '2,5,8' to remove packages 2, 5, and 8" $Blue
    Write-ColorOutput "   Or press Enter to install all packages" $Blue
}

function Get-FilteredPackages {
    param(
        [array]$Packages,
        [string]$RemoveInput
    )
    
    if ([string]::IsNullOrWhiteSpace($RemoveInput)) {
        return $Packages
    }
    
    # Parse the input - split by comma and clean up
    $numbersToRemove = @()
    $inputParts = $RemoveInput -split ','
    
    foreach ($part in $inputParts) {
        $trimmed = $part.Trim()
        if ($trimmed -match '^\d+$') {
            $number = [int]$trimmed
            if ($number -ge 1 -and $number -le $Packages.Length) {
                $numbersToRemove += $number
            } else {
                Write-ColorOutput "⚠ Warning: Package number '$number' is out of range (1-$($Packages.Length))" $Yellow
            }
        } elseif (-not [string]::IsNullOrWhiteSpace($trimmed)) {
            Write-ColorOutput "⚠ Warning: Invalid input '$trimmed' - expected a number" $Yellow
        }
    }
    
    if ($numbersToRemove.Length -eq 0) {
        return $Packages
    }
    
    # Remove duplicates and sort in descending order
    $numbersToRemove = $numbersToRemove | Sort-Object -Unique -Descending
    
    # Create filtered package list
    $filteredPackages = @()
    for ($i = 0; $i -lt $Packages.Length; $i++) {
        $packageNumber = $i + 1
        if ($numbersToRemove -notcontains $packageNumber) {
            $filteredPackages += $Packages[$i]
        } else {
            Write-ColorOutput "✗ Removed: $($Packages[$i].Name)" $Red
        }
    }
    
    Write-ColorOutput "`n✓ Final package list contains $($filteredPackages.Length) of $($Packages.Length) packages" $Green
    return $filteredPackages
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

# Show package selection (unless in quiet mode)
if (-not $Quiet) {
    Show-PackageSelection -Packages $packages
    $removeInput = Read-Host "`nEnter package numbers to remove (comma-separated) or press Enter to install all"
    $packages = Get-FilteredPackages -Packages $packages -RemoveInput $removeInput
}

Write-ColorOutput "`n🚀 Starting installation process..." $Green
Write-ColorOutput "This may take several minutes depending on your internet connection..." $Yellow

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
2. Open Windows Terminal and run 'wsl --install' to set up Linux
3. Install Git in WSL: 'sudo apt update && sudo apt install git'
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

if (-not $Quiet) {
    Read-Host "`nPress Enter to exit..."
}