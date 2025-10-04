# Changelog

All notable changes to this project will be documented in this file.

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