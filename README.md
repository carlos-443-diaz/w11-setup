# Windows 11 Setup Script

A comprehensive PowerShell script for setting up a new Windows 11 installation with essential software for **software development**, **information systems management**, and **graphics design**.

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
- **Git** - Industry-standard version control system
- **Windows Subsystem for Linux (WSL)** - Run Linux environments on Windows

### 🔧 Information Systems Management
- **1Password** - Secure password manager and digital vault
- **PowerToys** - Microsoft utilities for power users (FancyZones, PowerRename, etc.)

### 🎨 Graphics Design
- **GIMP** - Professional-grade image editing software
- **Inkscape** - Vector graphics editor for illustrations and logos
- **Paint.NET** - Lightweight yet powerful image editor

### 💻 Essential System Tools
- **7-Zip** - File archiver for various formats
- **VLC Media Player** - Versatile media player
- **Firefox** - Privacy-focused web browser

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

### 2. Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. VS Code Extensions (Recommended)
- **GitLens** - Enhanced Git capabilities
- **Prettier** - Code formatter
- **Live Server** - Local development server
- **Remote - WSL** - Develop in WSL environments

### 4. Windows Terminal Configuration
- Set as default terminal: Settings > Startup > Default terminal application
- Customize themes and profiles for different shells

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