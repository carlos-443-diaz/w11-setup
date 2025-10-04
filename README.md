# Windows 11 Setup Script

A comprehensive PowerShell script for setting up a new Windows 11 installation with essential software for **software development**, **information systems management**, **graphics design**, **system time configuration**, and **desktop customization**.

## 🚀 Quick Start

### One-Line Install (Recommended)
Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/carlos-443-diaz/w11-setup/main/setup-w11.ps1 | iex
```

### Manual Download
1. Download the script: [setup-w11.ps1](https://raw.githubusercontent.com/carlos-443-diaz/w11-setup/main/setup-w11.ps1)
2. Right-click **PowerShell** → **Run as Administrator**
3. Navigate to the download location and run:
   ```powershell
   .\setup-w11.ps1
   ```

## 📦 What Gets Installed

### 🛠️ Software Development
- **Visual Studio Code** - Modern code editor with extensive extensions
- **Windows Terminal Preview** - Enhanced terminal with tabs and customization (auto-pinned to taskbar)
- **Windows Subsystem for Linux (WSL)** - Run Linux environments with Git
- **Claude Code** - AI-powered coding assistant for enhanced productivity
- **UV** - Fast Python package installer and resolver for modern Python development

### 🔧 Information Systems Management
- **1Password** - Secure password manager and digital vault
- **PowerToys** - Microsoft utilities for power users (FancyZones, PowerRename, etc.)

### 🎨 Graphics Design & Media
- **GIMP** - Professional-grade image editing software
- **Inkscape** - Vector graphics editor for illustrations and logos
- **HandBrake** - Video transcoder and converter for various formats

### 💻 Essential System Tools
- **7-Zip** - File archiver for various formats
- **VLC Media Player** - Versatile media player
- **Firefox** - Privacy-focused web browser
- **Zen Browser** - Privacy-focused web browser with enhanced features

### 🎬 Media Codecs
- **HEIF Image Extensions** - Support for modern HEIF/HEIC image formats

### 🕒 Time & Date Configuration
- **Automatic Time Synchronization** - NTP time sync with time.windows.com
- **Timezone Detection** - Automatic timezone configuration based on location
- **Enhanced Time Format** - 24-hour format with seconds display
- **Location Services** - Enables location-based timezone updates

### 🖥️ Desktop & Taskbar Customization
- **Dark Theme** - Configures Windows 11 to use dark theme system-wide
- **Taskbar Auto-Hide** - Enables automatic taskbar hiding for more screen space
- **Clean Taskbar Layout** - Removes search box, task view, and Copilot buttons
- **Widget Configuration** - Disables sports content and unnecessary widgets
- **Optimized for Productivity** - Streamlined interface for development work

### ⚙️ Terminal Configuration
- **Windows Terminal Preview** - Automatically pinned to taskbar for easy access
- **Smart Default Profile** - WSL (if available) or PowerShell as fallback
- **Development Optimized** - Ready for immediate development workflow

## ⚡ Script Options

```powershell
# Run silently without prompts
.\setup-w11.ps1 -Quiet

# Run completely silent (no output, no prompts)
.\setup-w11.ps1 -Force

# Skip winget source updates
.\setup-w11.ps1 -SkipUpdates

# Specify WSL Linux distribution
.\setup-w11.ps1 -WSLDistro "Ubuntu-22.04"

# Combine options for fully automated installation
.\setup-w11.ps1 -Force -SkipUpdates -WSLDistro "Debian"

# Interactive mode with WSL distribution selection (default)
.\setup-w11.ps1
```

### Parameter Details

- **`-Quiet`** - Suppresses interactive prompts but shows installation progress
- **`-Force`** - Completely silent execution with no prompts or progress output
- **`-SkipUpdates`** - Skips updating winget sources before installation
- **`-WSLDistro`** - Specifies the Linux distribution for WSL (default: Ubuntu)

### Available WSL Distributions

When running interactively, you can choose from:
- **Ubuntu** (default) - Most popular, great for beginners
- **Ubuntu-22.04** - Long-term support version
- **Ubuntu-20.04** - Older LTS version  
- **Debian** - Stable and lightweight
- **kali-linux** - Security and penetration testing
- **openSUSE-Leap-15.5** - Enterprise-ready
- **Alpine** - Minimal and security-focused

## 📋 Prerequisites

- **Windows 11** (required)
- **Administrator privileges** (required)
- **Winget package manager** (usually pre-installed)
- **Internet connection** for downloads

### Installing Winget (if missing)
If winget is not available, install it from:
- **Microsoft Store**: Search for "App Installer"
- **GitHub**: [microsoft/winget-cli releases](https://github.com/microsoft/winget-cli/releases)

## 🔧 Post-Installation Setup

### 1. Complete WSL Setup
```powershell
# After restart, install your preferred Linux distribution
wsl --install -d Ubuntu
```

### 2. Install and Configure Git in WSL
```bash
# Install Git in WSL
sudo apt update && sudo apt install git

# Configure Git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. VS Code Extensions (Recommended)
- **GitLens** - Enhanced Git capabilities
- **Prettier** - Code formatter
- **Live Server** - Local development server
- **Remote - WSL** - Develop in WSL environments

### 4. Windows Terminal Configuration
- **Automatically configured** - Terminal is already pinned to taskbar with optimal default profile
- **Default profile** - Set to WSL (if available) or PowerShell as fallback
- **Optional customization** - Adjust themes and additional profiles in Settings as needed

### 5. Verify System Configuration
- **Time Settings**: Check time zone in **Settings > Time & Language > Date & Time**
  - Ensure "Set time automatically" and "Set time zone automatically" are enabled
  - Time format should display as 24-hour with seconds (HH:mm:ss)
  - If timezone is incorrect, manually select the correct one
- **Desktop Theme**: Verify dark theme is applied in **Settings > Personalization > Colors**
  - Choose "Dark" mode for better visual consistency
- **Taskbar Settings**: Check taskbar configuration in **Settings > Personalization > Taskbar**
  - Taskbar should auto-hide (move mouse to bottom to reveal)
  - Search, Task view, and widget buttons should be hidden
  - Verify clean, minimal taskbar layout

### 7. Additional Customizations (Optional)
- **PowerToys Configuration**: Launch PowerToys and configure FancyZones for window management
- **Terminal Themes**: Customize Windows Terminal with your preferred color scheme
- **VS Code Theme**: Install a dark theme extension if desired (e.g., One Dark Pro)
- **Taskbar Icons**: Pin your most-used applications to the auto-hiding taskbar

## 🛡️ Security & Privacy

This script:
- ✅ Only installs software from official sources via winget
- ✅ Uses Microsoft's trusted package repository
- ✅ Requires explicit user confirmation before installation
- ✅ Can be reviewed before execution (open source)
- ✅ Does not collect or transmit personal data

## 🐛 Troubleshooting

### Script Won't Run
```powershell
# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Package Installation Warnings

Some packages may show warnings during installation. Here's what they mean:

#### Package Not Found
- **Issue**: Packages like "1Password CLI" or "HEVC Video Extensions" may not be available in winget
- **Solution**: These packages are now removed from the script or can be installed manually from:
  - Microsoft Store (for Store-exclusive packages)
  - Official vendor websites
  - The script will skip unavailable packages automatically

#### PowerToys Installation Error
- **Issue**: PowerToys may fail with installer error (exit code 2147942526)
- **Possible causes**: 
  - Previous version conflict
  - Windows system files need repair
  - Pending system updates
- **Solution**:
  1. Uninstall any existing PowerToys version
  2. Run Windows Update and install all updates
  3. Restart your computer
  4. Try installing PowerToys manually from [Microsoft PowerToys GitHub](https://github.com/microsoft/PowerToys/releases)

#### Package Already at Latest Version
- **Issue**: Warning about "No available upgrade found"
- **This is normal**: The script checks if packages are installed and tries to ensure latest version
- **No action needed**: Package is already up-to-date

### WSL Installation Issues

#### Interactive Username Prompts
- **Issue**: WSL may try to prompt for username during script execution (now resolved)
- **Solution**: Script now uses `--no-launch` flag to prevent this
- **First Launch**: After restart, run `wsl -d <distro-name>` to complete username/password setup

#### WSL Not Available After Installation
- Enable "Windows Subsystem for Linux" in Windows Features
- Restart your computer after the initial script run
- Run `wsl --install -d <distro-name>` manually if needed

### Windows Terminal Taskbar Pinning

#### Access Denied Error
- **Issue**: Windows 11 restricts programmatic taskbar pinning for security
- **This is a Windows limitation**: PowerShell COM automation may be blocked
- **Solution**: Manually pin Windows Terminal:
  1. Open Start Menu
  2. Search for "Windows Terminal"
  3. Right-click and select "Pin to taskbar"

### Location Services and Timezone

#### Automatic Timezone Not Working
- **Issue**: Location services may need manual enabling
- **Solution**:
  1. Open **Settings > Privacy & Security > Location**
  2. Enable "Location services"
  3. Allow apps to access location
  4. Timezone should now update automatically

### Taskbar Widget Settings

#### Widget Configuration Warning
- **Issue**: Some registry settings may not apply immediately
- **Solution**:
  - Restart Windows Explorer: `taskkill /f /im explorer.exe && start explorer`
  - Or restart your computer
  - Some settings may require manual configuration in Windows Settings

### Known Limitations

The following cannot be fully automated due to Windows 11 security restrictions:
- **Taskbar pinning**: Requires manual user action in most cases
- **Location services**: Must be enabled manually by user for privacy reasons
- **Some registry settings**: May require restart or manual confirmation
- **Store-exclusive packages**: Cannot be installed via winget (HEVC extensions, etc.)

## 🤝 Contributing

Found an issue or want to suggest a package? 
- Open an [issue](https://github.com/carlos-443-diaz/w11-setup/issues)
- Submit a [pull request](https://github.com/carlos-443-diaz/w11-setup/pulls)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Show Your Support

If this script helped you set up your Windows 11 development environment, please give it a star! ⭐

---

**Made with ❤️ for the Windows development community**