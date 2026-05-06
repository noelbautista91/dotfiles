# dotfiles

NixOS and macOS system configurations using flakes, flake-parts, home-manager, and nix-darwin.

## Quick Start

```bash
# Clone
mkdir -p ~/Documents/Projects
cd ~/Documents/Projects
git clone <repo-url> dotfiles
cd dotfiles

# Rebuild (uses frozen flake.lock — deterministic)
bin/update

# Or update lockfile first, then rebuild
bin/update-lockfile
```

## Commands

| Command | Description |
|---|---|
| `update` | Rebuild system from frozen `flake.lock` (safe, reproducible) |
| `update-lockfile` | Update `flake.lock` to latest versions, then rebuild |
| `test-nixos-vm` | Build and launch a test VM |
| `pw` | 1Password CLI helper (copy password to clipboard) |

## Structure

```
dotfiles/
├── flake.nix                        # Flake entry point (inputs, flake-parts)
├── flake.lock                       # Pinned versions — DO NOT update casually
├── bin/
│   ├── update                        # Rebuild from frozen lockfile
│   ├── update-lockfile               # Update lockfile then rebuild
│   ├── pw                            # 1Password CLI helper
│   └── test-nixos-vm                 # Build + launch test VM
├── modules/
│   ├── nixos/                        # Shared NixOS system modules
│   │   ├── default.nix               # Aggregator — imports all sub-modules
│   │   ├── audio.nix                 # PipeWire, RTKit, graphics
│   │   ├── boot.nix                  # systemd-boot, EFI, kernel modules
│   │   ├── desktop.nix               # Plasma 6, SDDM, fonts, KDE Connect firewall
│   │   ├── gpu.nix                   # GPU config (AMD ROCm / Intel / NVIDIA)
│   │   ├── networking.nix            # NetworkManager, firewall, DNS (kresd)
│   │   ├── nix.nix                   # Nix daemon settings, garbage collection, nix-ld
│   │   ├── packages.nix              # System-level packages (zsh, nodejs, rofi, etc.)
│   │   ├── security.nix              # SSH hardening, 1Password, firejail, Firefox
│   │   ├── services.nix              # Timezone, locale, libinput, btrfs
│   │   ├── users.nix                 # User creation, groups, SSH keys (option: my.user.name)
│   │   └── virtualization.nix        # Podman, Docker compat
│   ├── home-manager/                 # Shared home-manager user modules
│   │   ├── default.nix               # Aggregator — imports all sub-modules
│   │   ├── cli.nix                   # zsh, git, ssh, tmux, direnv, distrobox, aliases, session vars, PATH
│   │   ├── editors.nix              # Neovim
│   │   ├── browsers.nix             # Firefox (default browser)
│   │   ├── terminal.nix             # Ghostty
│   │   ├── gui.nix                  # Plasma desktop config (shortcuts, kwin, theme)
│   │   └── packages.nix             # User packages (vlc, etc.)
│   └── darwin/                        # Shared macOS system modules
│       ├── default.nix               # macOS defaults (dock, finder, trackpad, keyboard)
│       └── homebrew.nix              # Homebrew package management
└── hosts/
    ├── orbiter/                       # AMD desktop (NixOS)
    │   ├── configuration.nix          # Thin: imports shared modules + orbiter overrides
    │   ├── hardware-configuration.nix # Auto-generated hardware config
    │   ├── flake-module.nix           # Flake wiring (NixOS + home-manager)
    │   └── nordvpn.nix                # Custom NordVPN NixOS module
    └── test-vm/                        # QEMU test VM (NixOS)
        ├── default.nix                # VM overrides (VM hardware, empty passwords)
        └── flake-module.nix           # Flake wiring
```

## Adding a New NixOS Machine

1. Create `hosts/<hostname>/` with:
   - `hardware-configuration.nix` — generate via `nixos-generate-config` or copy from install
   - `configuration.nix` — thin file importing `../../modules/nixos` plus host-specific overrides
   - `flake-module.nix` — copy from `hosts/orbiter/flake-module.nix`, change hostname and system
2. Add the new `flake-module.nix` to `flake.nix` imports list
3. Run `update-lockfile` to build

## Adding a macOS Machine

1. Create `hosts/<hostname>/flake-module.nix` using `nix-darwin` and `home-manager` standalone (not NixOS module)
2. Import `modules/darwin` for system defaults and `modules/home-manager` for user config (skip `gui.nix`)
3. Add to `flake.nix` imports list

## Adding a NixOS Machine

## Modifying Shared Config

| What | Where |
|---|---|
| System package (all NixOS) | `modules/nixos/packages.nix` → `environment.systemPackages` |
| User package (all machines) | `modules/home-manager/packages.nix` → `home.packages` |
| Shell alias | `modules/home-manager/cli.nix` → `programs.zsh.shellAliases` |
| GPU config (per-host) | Host `configuration.nix` → `my.hardware.gpu.type` |
| Default user | `modules/nixos/users.nix` → `my.user.name` default, or override per-host |
| Plasma shortcuts | `modules/home-manager/gui.nix` → `programs.plasma.shortcuts` |
| Firewall port | `modules/nixos/networking.nix` → `networking.firewall.allowedTCPPorts`/`allowedUDPPorts` |

## Testing

```bash
# Quick syntax check (fast, no build)
nix flake check

# Full system test in a VM
bin/test-nixos-vm

# Apply to orbiter
bin/update
```

## VM Testing

The test VM is configured with 4GB RAM, 2 cores, 20GB disk, and SSH on port 2222.

```bash
# Build and launch
bin/test-nixos-vm

# SSH into the VM
ssh -p 2222 root@localhost
```

## Conventions

- Shared modules use `lib.mkDefault` so hosts can override values
- Host-specific overrides go in the host's `configuration.nix`, never in shared modules
- Custom NixOS modules use the `noelbautista91` namespace
- Custom options use the `my` namespace (`my.hardware.gpu`, `my.user.name`)
- `flake.lock` is the version freeze — never run `nix flake update` casually; use `update-lockfile`

## Requirements

- Nix with flakes enabled
- sudo access (for NixOS system configuration)