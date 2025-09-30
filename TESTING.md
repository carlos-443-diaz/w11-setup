# Windows 11 Setup Script Test Guide

This document explains how to test the Windows 11 setup script.

## Quick Test Command

On Windows 11 with PowerShell as Administrator:
```powershell
# Test with prompts
.\setup-w11.ps1

# Test silently (no prompts)
.\setup-w11.ps1 -Quiet

# Test without updating winget sources
.\setup-w11.ps1 -SkipUpdates

# Test both options
.\setup-w11.ps1 -Quiet -SkipUpdates
```

## Direct Download and Run
```powershell
# Download and run in one command
irm https://raw.githubusercontent.com/carlos-443-diaz/w11-setup/main/setup-w11.ps1 | iex
```

## What to Expect

The script will:
1. Show a banner with the script purpose
2. Check for Administrator privileges
3. Verify winget is installed
4. Update winget sources (unless -SkipUpdates is used)
5. Show installation summary
6. Install each package with progress indicators
7. Configure time and date settings
8. Display completion message with next steps

## Package Categories Installed

### Development Tools
- Microsoft.VisualStudioCode
- Microsoft.WindowsTerminal.Preview  
- Microsoft.WSL

### Security & Productivity
- AgileBits.1Password
- AgileBits.1PasswordCLI
- Microsoft.PowerToys

### Graphics Design
- GIMP.GIMP
- Inkscape.Inkscape

### System Utilities
- 7zip.7zip
- VideoLAN.VLC
- Mozilla.Firefox

### Time Configuration
- Automatic NTP time synchronization
- Automatic timezone detection
- Enhanced time display format (24-hour with seconds)
- Location-based timezone configuration

## Troubleshooting

### If winget is not found:
1. Install from Microsoft Store (App Installer)
2. Or download from: https://github.com/microsoft/winget-cli/releases

### If script won't run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### If packages fail to install:
- Check internet connection
- Run `winget source update`
- Some packages may need a restart

## Expected Output

Look for these indicators:
- ✓ Green checkmarks for successful installations
- ⚠ Yellow warnings for packages that may already be installed
- ✗ Red X marks for failed installations
- Blue info messages for progress updates