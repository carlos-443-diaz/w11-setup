# Windows 11 Setup Script

A comprehensive PowerShell script for setting up a new Windows 11 installation with essential software for **software development**, **information systems management**, **graphics design**, and **system time configuration**.

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
- **Windows Terminal Preview** - Enhanced terminal with tabs and customization
- **Windows Subsystem for Linux (WSL)** - Run Linux environments with Git

### 🔧 Information Systems Management
- **1Password** - Secure password manager and digital vault
- **1Password CLI** - Command-line interface for WSL integration
- **PowerToys** - Microsoft utilities for power users (FancyZones, PowerRename, etc.)

### 🎨 Graphics Design & Media
- **GIMP** - Professional-grade image editing software
- **Inkscape** - Vector graphics editor for illustrations and logos
- **HandBrake** - Video transcoder and converter for various formats

### 💻 Essential System Tools
- **7-Zip** - File archiver for various formats
- **VLC Media Player** - Versatile media player
- **Firefox** - Privacy-focused web browser

### 🎬 Media Codecs
- **HEIF Image Extensions** - Support for modern HEIF/HEIC image formats
- **HEVC Video Extensions** - Advanced H.265/HEVC video codec support

### 🕒 Time & Date Configuration
- **Automatic Time Synchronization** - NTP time sync with time.windows.com
- **Timezone Detection** - Automatic timezone configuration based on location
- **Enhanced Time Format** - 24-hour format with seconds display
- **Location Services** - Enables location-based timezone updates

## ⚡ Script Options

```powershell
# Run silently without prompts
.\setup-w11.ps1 -Quiet

# Skip winget source updates
.\setup-w11.ps1 -SkipUpdates

# Combine options
.\setup-w11.ps1 -Quiet -SkipUpdates
```

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

### 3. Set up 1Password CLI for WSL
```bash
# The 1Password CLI is already installed on Windows
# Configure it for use in WSL following the official guide
```

### 4. VS Code Extensions (Recommended)
- **GitLens** - Enhanced Git capabilities
- **Prettier** - Code formatter
- **Live Server** - Local development server
- **Remote - WSL** - Develop in WSL environments

### 5. Windows Terminal Configuration
- Set as default terminal: Settings > Startup > Default terminal application
- Customize themes and profiles for different shells

### 6. Verify Time Configuration
- Check time zone in **Settings > Time & Language > Date & Time**
- Ensure "Set time automatically" and "Set time zone automatically" are enabled
- Time format should display as 24-hour with seconds (HH:mm:ss)
- If timezone is incorrect, manually select the correct one

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

### Package Installation Fails
- Ensure you have an active internet connection
- Try running `winget source update` manually
- Some packages may require a system restart

### WSL Installation Issues
- Enable "Windows Subsystem for Linux" in Windows Features
- Restart your computer after the initial script run
- Run `wsl --install` manually if needed

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