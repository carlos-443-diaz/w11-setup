# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0] - 2024-12-19

### Added
- **Windows Terminal Configuration** - Automated terminal setup and optimization
  - Automatically pins Windows Terminal Preview to taskbar for easy access
  - Smart default profile configuration (WSL if available, PowerShell as fallback)
  - WSL detection to determine optimal default terminal profile
  - Enhanced user experience with automated terminal workflow setup

### Changed
- Updated script banner and description to include terminal configuration
- Enhanced installation summary to highlight terminal optimization features
- Improved completion message with terminal-specific configuration notes
- Updated next steps guidance to reflect automated terminal setup

## [1.2.0] - 2024-12-19

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

## [1.1.0] - 2024-09-30

### Changed
- Removed Paint.NET from graphics design tools
- Removed Windows Git installation (Git now handled via WSL)
- Removed batch file launcher (`run-setup.bat`)
- Updated documentation to reflect WSL-based Git workflow

### Added
- 1Password CLI for WSL integration
- Enhanced post-installation guidance for WSL Git setup

## [1.0.0] - 2024-09-30

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