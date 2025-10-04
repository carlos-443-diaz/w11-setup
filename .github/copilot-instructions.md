# Copilot Instructions for w11-setup

## Project Overview
This repository contains a PowerShell-based automation script for setting up new Windows 11 installations. The script automates the installation of essential software packages using the winget package manager and configures system settings for an optimal development environment.

## Purpose
The `setup-w11.ps1` script provides a one-command solution for:
- Installing development tools (VS Code, Windows Terminal, WSL)
- Setting up information systems management tools (1Password, PowerToys)
- Installing graphics design software (GIMP, Inkscape, HandBrake)
- Configuring system utilities and media codecs
- Automating time/date synchronization and timezone configuration
- Customizing desktop theme and taskbar settings
- Configuring Windows Terminal default profile

## Key Technologies
- **PowerShell**: Primary scripting language (Windows PowerShell 5.1+ or PowerShell Core 7+)
- **winget**: Windows Package Manager for software installation
- **Windows Registry**: Used for system configuration (theme, taskbar, widgets)
- **WSL (Windows Subsystem for Linux)**: Optional Linux environment setup

## Code Structure
- `setup-w11.ps1`: Main script containing all installation and configuration logic
- `README.md`: User-facing documentation with installation instructions and feature descriptions
- `CHANGELOG.md`: Version history and feature documentation
- `TESTING.md`: Testing guide and validation procedures
- `LICENSE`: MIT License file

## Coding Standards and Practices

### PowerShell Style
- Use descriptive function names with verb-noun pattern (e.g., `Configure-TimeSettings`, `Install-WingetPackage`)
- Include comprehensive parameter documentation with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, and `.NOTES` blocks
- Use proper error handling with `try-catch` blocks and `$ErrorActionPreference`
- Implement colored output for better user experience using `Write-ColorOutput` function
- Support cross-platform testing with simulation mode for non-Windows environments

### Script Parameters
- `SkipUpdates`: Skip updating winget sources
- `Quiet`: Suppress interactive prompts but show progress
- `Force`: Completely silent execution
- `WSLDistro`: Specify WSL Linux distribution (default: Ubuntu)

### Code Organization
1. Parameter definitions and setup
2. Helper functions (color output, checks)
3. Display functions (banner, summary)
4. Package installation functions
5. System configuration functions (time, desktop, taskbar, terminal)
6. Main execution flow
7. Post-installation messages

### Important Patterns
- **Idempotent operations**: Script checks if packages are already installed before attempting installation
- **Cross-platform support**: Uses `$PSVersionTable.Platform` checks for simulation mode on non-Windows
- **Administrator checks**: Script requires admin privileges and verifies them at startup
- **Registry modifications**: All system configurations use Windows Registry with proper error handling
- **User feedback**: Comprehensive colored output with status indicators (✓, ✗, ⚠, 🎉)

## Testing Approach
- Test on actual Windows 11 systems when possible
- Use simulation mode on non-Windows platforms (automatically detected)
- Verify each package installation individually
- Test both interactive and quiet modes
- Validate system configuration changes (theme, taskbar, time settings)
- Check idempotent behavior by running script multiple times

## Common Tasks

### Adding a New Package
1. Add package entry to `$packages` array with Id, Name, and Category
2. Update `Show-Summary` function to include the new package
3. Update `Show-Banner` if adding a new category
4. Document in README.md under "What Gets Installed"
5. Add to TESTING.md package list
6. Update CHANGELOG.md with the addition

### Adding System Configuration
1. Create a new function following the pattern: `Configure-<Feature>Settings`
2. Include cross-platform check for simulation mode
3. Use proper Registry paths and error handling
4. Add colored status output
5. Call the function in main execution flow
6. Document in README.md and CHANGELOG.md

### Modifying Registry Settings
- Always use `Test-Path` before accessing registry keys
- Use `-ErrorAction SilentlyContinue` for properties that may not exist
- Provide clear warning messages when settings can't be applied
- Test registry changes thoroughly as they affect system behavior

## Documentation Standards
- Keep README.md user-friendly with clear installation instructions
- Use emoji for visual appeal and section identification
- Maintain detailed CHANGELOG.md following Keep a Changelog format
- Include version numbers and dates for all releases
- Document both features and technical changes

## Security Considerations
- Script requires administrator privileges (enforced with `#Requires -RunAsAdministrator`)
- Uses official winget packages from trusted sources only
- Requires explicit user confirmation before installation (unless `-Force` is used)
- No personal data collection or transmission
- Open source for transparency and community review
- Set appropriate execution policy: `RemoteSigned` for current user only

## Version History
The project follows semantic versioning:
- v1.0.0: Initial release with core software installation
- v1.1.0: Added quiet mode and improved output
- v1.2.0: Time/date configuration and idempotent installation
- v1.3.0: Desktop customization and Windows Terminal configuration
- v1.3.1: Added Zen Browser

## When Modifying This Repository
1. Maintain backward compatibility with existing parameters
2. Preserve the user-friendly nature of the script
3. Test thoroughly on Windows 11 before committing
4. Update all documentation (README, CHANGELOG, TESTING)
5. Keep the script as a single file for easy distribution
6. Ensure cross-platform simulation mode continues to work
7. Follow the established naming and organizational patterns
8. Maintain colored output consistency
9. Add appropriate error handling for all new features
10. Consider idempotent behavior for all operations

## Target Audience
- Windows 11 users setting up new installations
- Software developers needing a standardized development environment
- IT professionals managing multiple Windows 11 systems
- Power users who want automated system configuration

## Script Distribution
The script is designed to be run directly from GitHub using:
```powershell
irm https://raw.githubusercontent.com/carlos-443-diaz/w11-setup/main/setup-w11.ps1 | iex
```

This means all functionality must be self-contained in the single PowerShell script file.
