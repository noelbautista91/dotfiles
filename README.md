# dotfiles

NixOS and home-manager configurations using flakes.

## Quick Start

```bash
# Clone and enter the directory
mkdir -p ~/Documents/Projects
cd ~/Documents/Projects
git clone <your-repo-url> dotfiles
cd dotfiles

# Build the system (requires sudo)
./bin/rebuild orbiter
```

## Usage

### Rebuild the system

```bash
./bin/rebuild
```

This will rebuild the NixOS configuration and home-manager together.

### Update packages and rebuild

```bash
./bin/pkgs_update
```

This updates the flake inputs and rebuilds the system.

## Structure

```
.
├── flake.nix                 # Flake entry point
├── hosts/
│   └── orbiter/              # Host-specific NixOS config
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── nordvpn.nix
├── home-manager/
│   └── home.nix              # Home-manager configuration
└── bin/
    ├── rebuild               # Quick rebuild script
    └── pkgs_update           # Update and rebuild script
```

## Requirements

- Nix with flakes enabled
- sudo access (for system configuration)

## Notes

- Uses `nixos-unstable` channel via flake
- Home-manager is integrated with nixos-rebuild (no separate command needed)
