# Changelog

All notable changes to this project will be documented in this file.

## [1.3.4] - 2025-10-04

### Added
- **UV Python Package Manager** (Issue #13)
  - Added astral-sh.uv package for fast Python package installation and resolution
  - UV provides modern Python dependency management with faster resolution than pip
  - Updated installation summary to include UV in development tools

### Fixed
- **Package Installation Improvements** (Issue #13)
  - Removed 1Password CLI (AgileBits.1PasswordCLI) - package not available in winget
  - Removed HEVC Video Extensions (9N4WGH0Z6VHQ) - not available on all systems
  - Improved error handling for package not found errors (exit code -1978335212)
  - Better handling of already-installed packages with upgrade checks (exit code -1978335189)
  - Now shows "already at latest version" instead of warning for up-to-date packages
  
- **WSL Installation Enhancements** (Issue #13)
  - Added `--no-launch` flag to WSL installation to prevent interactive username prompts during script execution
  - First launch of WSL after restart will prompt for username and password setup
  - Prevents installation failures due to interactive prompts
  - Better user guidance on completing WSL setup after restart

- **Windows Terminal Taskbar Pinning** (Issue #13)
  - Improved error handling for taskbar pinning access denied errors
  - Added user-friendly instructions for manual pinning when automated pinning fails
  - Better logging of pinning failures with actionable guidance
  - Added notes about Windows 11 security restrictions on programmatic taskbar pinning

### Changed
- **Enhanced Error Reporting**
  - Install-WingetPackage now handles specific exit codes with appropriate messages
  - Better differentiation between package not found vs installation warnings
  - Improved user feedback for packages that are already up-to-date
  - More informative logging for troubleshooting

- **Updated Documentation**
  - Removed references to 1Password CLI from installation summary and tips
  - Updated completion message to clarify WSL first-launch setup process
  - Added guidance for manual Windows Terminal taskbar pinning
  - Clearer instructions for post-restart WSL configuration

## [1.3.3] - 2025-10-04

### Fixed
- **Package Installation Issues** (Issue #12)
  - Replaced Claude Desktop with Claude Code (Anthropic.ClaudeCode) as requested
  - Fixed GIMP package ID - now uses Microsoft Store version (9PNSJCLXDZ0V) instead of GIMP.GIMP
  - Improved WSL distribution installation with better error capture and logging

### Added
- **Error Logging System** (Issue #12)
  - Comprehensive error logging to track installation failures
  - Log files saved to `$env:TEMP\w11-setup-log.txt` (full log) and `$env:TEMP\w11-setup-errors.txt` (errors only)
  - Log file paths displayed at start and end of script execution
  - All installation errors and warnings now captured with detailed output
  - Enhanced troubleshooting with timestamped log entries

### Changed
- **Improved Installation Experience**
  - Enhanced error messages now include references to log files for detailed troubleshooting
  - Better error capture in `Install-WingetPackage` function with exit code and output logging
  - Improved `Install-WSLDistribution` function with detailed output capture
  - All messages now automatically logged with appropriate severity levels
  - Updated documentation to reflect Claude Code instead of Claude Desktop

## [1.3.2] - 2025-10-04

### Fixed
- **Critical Bug Fixes** (Issue #8)
  - Fixed Write-Host color binding error by adding missing `$White` color variable
  - Fixed widget configuration permission errors with improved error handling and path creation
  - Fixed WSL distribution installation - now properly installs selected Linux distro after WSL package installation
  - Added `Install-WSLDistribution` function to handle distro installation with proper error recovery

### Added
- **Claude Desktop** - AI-powered coding assistant
  - Added Anthropic.Claude package to development tools
  - Updated installation summary to include Claude Desktop
  - Enhanced post-installation guidance for AI assistance

### Changed
- **Improved Installation Experience**
  - Enhanced completion message with stronger emphasis on restart requirement
  - Improved error handling for registry operations in widget configuration
  - Better post-installation instructions with clearer restart requirements
  - Updated next steps to include Claude Desktop launch
  - Added recommendations for Windows Terminal settings import and PowerToys configuration

## [1.3.1] - 2025-09-30

### Added
- **Zen Browser** - Privacy-focused web browser with enhanced features
  - Added zen-team.zen-browser package to Essential System Tools
  - Updated documentation to include Zen Browser description
  - Added to testing guide package list
  - Rebased on latest main branch with quiet install mode and terminal configuration features

### Fixed
- Resolved issue with zen and GIMP installations by adding missing Zen Browser
- Verified GIMP.GIMP package ID is correctly configured
- Applied changes on top of latest main branch improvements

## [1.3.0] - 2025-09-30

### Added
- **Desktop & Taskbar Customization** - Comprehensive desktop personalization
  - Automatic dark theme configuration for Windows 11
  - Taskbar auto-hide functionality for maximized screen space
  - Clean taskbar layout with removal of search box, task view, and Copilot buttons
  - Widget configuration to disable sports content and unnecessary widgets
  - Streamlined interface optimized for development productivity
- **Enhanced User Experience**
  - Updated script banner to include desktop customization
  - Enhanced completion message with desktop configuration guidance
  - Comprehensive post-installation verification steps for all settings
- **Registry-based Configuration** - Professional system customization
  - SystemUsesLightTheme and AppsUseLightTheme registry settings for dark theme
  - TaskbarAutoHideInDesktopMode for auto-hiding taskbar
  - SearchboxTaskbarMode, ShowTaskViewButton, and ShowCopilotButton for clean taskbar
  - Widget and feed configuration through registry modifications
- **Windows Terminal Configuration** - Automated terminal setup and optimization
  - Automatically pins Windows Terminal Preview to taskbar for easy access
  - Smart default profile configuration (WSL if available, PowerShell as fallback)
  - WSL detection to determine optimal default terminal profile
  - Enhanced user experience with automated terminal workflow setup

### Changed
- Updated script description to include desktop customization and theme configuration
- Updated script banner and description to include terminal configuration
- Enhanced README.md with detailed desktop and taskbar customization documentation
- Enhanced installation summary to highlight terminal optimization features
- Improved post-installation guidance with system verification steps
- Improved completion message with terminal-specific configuration notes
- Expanded completion message to include desktop configuration tips
- Updated next steps guidance to reflect automated terminal setup

## [1.2.0] - 2025-09-30

### Added
- **Time & Date Configuration** - Comprehensive time setup functionality
  - Automatic time synchronization with NTP servers (time.windows.com)
  - Automatic timezone detection and configuration
  - Enhanced time display format (24-hour with seconds)
  - Location-based timezone updates configuration
- **New Media Software & Codecs**
  - HandBrake - Video transcoder and converter
  - HEIF Image Extensions - Modern image format support
  - HEVC Video Extensions - Advanced video codec support
- **Idempotent Package Installation** - Script can be run multiple times safely
  - Checks if packages are already installed before attempting installation
  - Prevents errors and unnecessary reinstallation
  - Provides clear status messages for existing vs. newly installed packages
- Updated banner and summary to reflect new features
- Enhanced post-installation guidance for time settings verification

### Changed
- Updated script description to include time configuration and new media tools
- Enhanced completion message with time-related next steps
- Reorganized package categories for better organization
- Improved package installation feedback and error handling

## [1.1.0] - 2025-09-29

### Changed
- Removed Paint.NET from graphics design tools
- Removed Windows Git installation (Git now handled via WSL)
- Removed batch file launcher (`run-setup.bat`)
- Updated documentation to reflect WSL-based Git workflow

### Added
- 1Password CLI for WSL integration
- Enhanced post-installation guidance for WSL Git setup

## [1.0.0] - 2025-09-29

### Added
- Initial release of Windows 11 Setup Script
- PowerShell script (`setup-w11.ps1`) for automated software installation
- Comprehensive README.md with installation and usage instructions
- MIT License for open source distribution
- Testing guide (TESTING.md) with validation instructions

### Features
- **Software Development Tools**:
  - Visual Studio Code
  - Windows Terminal Preview
  - Windows Subsystem for Linux (WSL)

- **Information Systems Management**:
  - 1Password password manager
  - 1Password CLI for WSL integration
  - PowerToys utilities

- **Graphics Design Software**:
  - GIMP image editor
  - Inkscape vector graphics

- **Essential System Tools**:
  - 7-Zip file archiver
  - VLC Media Player
  - Firefox web browser

### Technical Features
- Cross-platform testing support (simulation mode on non-Windows)
- Administrator privilege verification
- Winget availability checking
- Colored output for better user experience
- Silent mode option (`-Quiet`)
- Skip updates option (`-SkipUpdates`)
- Error handling and user confirmations
- Post-installation guidance and tips

### Security
- Uses only official winget packages from trusted sources
- Requires explicit user confirmation before installation
- No personal data collection or transmission
- Open source for transparency and review