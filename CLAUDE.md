   **Note**: This project uses [bd (beads)](https://github.com/steveyegge/beads)
   for issue tracking. Use `bd` commands instead of markdown TODOs.
   See AGENTS.md for workflow details.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing development environment configurations across Linux (Fedora) and macOS systems. The repository uses a bare git repository approach with symbolic links for configuration management.

## Installation and Setup

### Primary Installation Method
Run `./install.sh` from the repository root to set up symbolic links for configuration files:
- Creates symlinks for `.zshrc`, `.gitconfig` 
- Links configuration files from `.config/` directory to `~/.config/`
- The script safely handles existing files and directories

### Package Management
- `pkglist.txt` contains a list of installed Fedora packages for system restoration
- Generate updated package list: `dnf repoquery --userinstalled --qf '%{name}\n' > pkglist.txt`

## Key Configuration Files

### Shell Configuration (.zshrc)
- Uses Oh My Zsh framework with robbyrussell theme
- Key plugins: git, 1password, dotenv, ssh, dnf
- Custom aliases for common tasks:
  - `dotfiles`: Git wrapper for managing this repository (`git --git-dir=$HOME/Projects/dotfiles/ --work-tree=$HOME`)
  - `proj`: Navigate to `$HOME/Documents/Projects/`
  - `pkglist`: Generate package backup list
  - `pbcopy`/`pbpaste`: Clipboard utilities (wl-clipboard wrappers)
- System update reminders (bi-weekly check)
- Environment setup for NVM, SDKMAN, GPG, and various development tools

### Git Configuration (.gitconfig)
- Configured for SSH signing with 1Password integration
- Uses `op-ssh-sign` for commit and tag signing
- User: Noel Bautista <noel@noynoy.org>

### Utility Scripts
- `bin/pw`: 1Password CLI script for secure password retrieval with auto-clearing clipboard

## Development Environment

### System Management Functions
- `update_fedora()`: System update with cleanup (`sudo dnf update && sudo dnf upgrade && cleanup`)
- `cleanup_fedora()`: Clean package cache (`sudo dnf clean all`)  
- `check_for_update()`: Automated bi-weekly update reminders

### Key Environment Variables
- `EDITOR=nvim` (primary), falls back to `vim` over SSH
- Custom PATH includes Go binaries, local bins, SDKMAN, NVM
- GPG_TTY properly configured for signing

## File Structure

```
├── .zshrc          # Main shell configuration
├── .zshenv         # Zsh environment setup (ZDOTDIR)
├── .gitconfig      # Git configuration with SSH signing
├── install.sh      # Setup script for symbolic links
├── pkglist.txt     # Fedora package list backup
├── bin/            # Custom utility scripts
│   └── pw          # 1Password password retrieval script
└── archive/        # Archived configurations
```

## Common Workflows

### Managing This Repository
Use the `dotfiles` alias for all git operations:
```bash
dotfiles status
dotfiles add .zshrc
dotfiles commit -m "Update shell config"
dotfiles push
```

### System Maintenance
- Run `update_fedora` for system updates
- Use `pkglist` alias to backup installed packages
- Monitor system with built-in update reminder system

## Platform Support
- Primary: Fedora Linux with KDE Plasma
- Secondary: macOS support mentioned in README
- Uses conditional logic in shell config for cross-platform compatibility
