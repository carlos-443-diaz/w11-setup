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
6. **NEW**: Show package selection (unless -Quiet is used)
7. Allow user to remove unwanted packages by number
8. Check each package and install only if not already present (idempotent)
9. Configure time and date settings
10. Display completion message with next steps

## Package Selection Feature

**NEW in v1.3.0**: The script now includes interactive package selection:

### Testing Package Selection
When running interactively (without `-Quiet`), the script will:
1. Display a numbered list of all packages
2. Prompt for packages to remove (comma-separated numbers)
3. Validate input and show warnings for invalid entries
4. Display final package list before installation

### Examples to Test
```powershell
# Test interactive mode with package removal
.\setup-w11.ps1
# When prompted, try: "7,9,14" to remove GIMP, HandBrake, HEVC Extensions

# Test with invalid input
.\setup-w11.ps1
# When prompted, try: "0,15,abc" to see error handling

# Test quiet mode (skips package selection)
.\setup-w11.ps1 -Quiet
```

## Re-running the Script

The script is designed to be **idempotent** - it can be run multiple times safely without causing errors or reinstalling existing packages. When run again, it will:
- Check if each package is already installed
- Skip installation for existing packages
- Only install missing packages
- Reconfigure time settings if needed

## Package Categories Installed

### Development Tools
- Microsoft.VisualStudioCode
- Microsoft.WindowsTerminal.Preview  
- Microsoft.WSL

### Security & Productivity
- AgileBits.1Password
- AgileBits.1PasswordCLI
- Microsoft.PowerToys

### Graphics Design & Media
- GIMP.GIMP
- Inkscape.Inkscape
- HandBrake.HandBrake

### System Utilities
- 7zip.7zip
- VideoLAN.VLC
- Mozilla.Firefox

### Media Codecs
- 9PMMSR1CGPWG (HEIF Image Extensions)
- 9N4WGH0Z6VHQ (HEVC Video Extensions)

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