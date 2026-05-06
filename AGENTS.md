# AGENTS.md

## Shell Aliases

All shell aliases are managed in `modules/home-manager/cli.nix` under `programs.zsh.shellAliases`.

When adding a new alias, add it to the `shellAliases` attribute set in that file. For example:

```nix
shellAliases = {
  opencode-dev = "nix run ${config.home.homeDirectory}/Documents/Projects/opencode";
};
```

## System Updates

- **`update`** — Rebuilds the system using frozen `flake.lock`. Safe, deterministic, reproducible.
- **`update-lockfile`** — Updates `flake.lock` to latest versions, then rebuilds. Use intentionally when you want new package versions.

Both scripts live in `bin/` and are on PATH via `home.sessionPath` in `modules/home-manager/cli.nix`.

`flake.lock` is the version freeze. Never run `nix flake update` casually — always use `update-lockfile`.

## Repo Structure

```
dotfiles/
├── flake.nix                        # Flake entry point (inputs, flake-parts)
├── flake.lock                       # Pinned versions — DO NOT update casually
├── bin/
│   ├── update                        # Rebuild from frozen lockfile
│   ├── update-lockfile               # Update lockfile then rebuild
│   ├── pw                            # 1Password CLI helper
│   └── test-nixos-vm                 # Build + launch test VM
├── config/
│   ├── mcpu/
│   │   └── config.json               # MCP multiplexer server definitions (mcpu)
│   └── opencode/
│       └── AGENTS.md                 # Global opencode instructions
├── modules/
│   ├── nixos/                        # Shared NixOS system modules
│   │   ├── default.nix               # Aggregator — imports all sub-modules
│   │   ├── audio.nix                 # PipeWire, RTKit, graphics
│   │   ├── boot.nix                  # systemd-boot, EFI, kernel modules
│   │   ├── desktop.nix               # Plasma 6, SDDM, fonts, KDE Connect firewall
│   │   ├── gpu.nix                   # GPU config (AMD ROCm / Intel / NVIDIA)
│   │   ├── networking.nix            # NetworkManager, firewall, DNS (kresd)
│   │   ├── nix.nix                   # Nix daemon settings, garbage collection, nix-ld
│   │   ├── packages.nix              # System-level packages (nodejs, etc.)
│   │   ├── security.nix              # SSH hardening, 1Password, firejail, Firefox
│   │   ├── services.nix              # Timezone, locale, libinput, btrfs
│   │   ├── users.nix                 # User creation, groups, SSH keys (option: my.user.name)
│   │   └── virtualization.nix        # Podman, Docker compat
│   ├── home-manager/                 # Shared home-manager user modules
│   │   ├── default.nix               # Aggregator — imports all sub-modules
│   │   ├── cli.nix                   # zsh, git, ssh, tmux, direnv, distrobox, aliases, session vars, PATH
│   │   ├── editors.nix              # Neovim
│   │   ├── browsers.nix             # Default browser (Firefox), xdg-mime defaults
│   │   ├── terminal.nix             # Ghostty
│   │   ├── gui.nix                  # Plasma desktop config (shortcuts, kwin, theme)
│   │   ├── rofi.nix                 # Rofi launcher config
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

## How to Add a New NixOS Machine

1. Create `hosts/<hostname>/` with:
   - `hardware-configuration.nix` — generate via `nixos-generate-config` or copy from install
   - `configuration.nix` — thin file importing `../../modules/nixos` plus host-specific overrides
   - `flake-module.nix` — copy from `hosts/orbiter/flake-module.nix`, change hostname and system
2. Add the new `flake-module.nix` to `flake.nix` imports list
3. Run `update-lockfile` to build

## How to Add a macOS Machine

1. Create `hosts/<hostname>/flake-module.nix` using `nix-darwin` and `home-manager` standalone (not NixOS module)
2. Import `modules/darwin` for system defaults and `modules/home-manager` for user config (skip `gui.nix`)
3. Add to `flake.nix` imports list

## How to Modify Shared Config

### Adding a system package (all NixOS machines)
Edit `modules/nixos/packages.nix` — add to the `environment.systemPackages` list.

### Adding a user package (all machines)
Edit `modules/home-manager/packages.nix` — add to `home.packages`.

### Adding a shell alias
Edit `modules/home-manager/cli.nix` — add to `programs.zsh.shellAliases`.

### Changing GPU config for a specific machine
Set `my.hardware.gpu.type` in the host's `configuration.nix`:
```nix
my.hardware.gpu = {
  enable = true;
  type = "amd";  # or "intel" or "nvidia"
};
```

### Changing the default user
Set `my.user.name` in `modules/nixos/users.nix` default or override per-host:
```nix
my.user.name = "differentuser";
```

### Adding KDE Plasma keyboard shortcuts
Edit `modules/home-manager/gui.nix` — add to `programs.plasma.shortcuts`.

### Adding a firewall port
Edit `modules/nixos/networking.nix` — add to `networking.firewall.allowedTCPPorts` or `allowedUDPPorts`.

### Adding an MCP server

MCP servers are managed through **mcpu**, an MCP multiplexer. opencode connects to mcpu as a single MCP server, and mcpu fans out to all upstream servers.

1. Edit `config/mcpu/config.json` — add a new server entry:
   ```json
   "my-server": {
     "command": "npx",
     "args": ["-y", "my-mcp-server"]
   }
   ```
2. If the new config file isn't already git-tracked, stage it: `git add config/mcpu/config.json`
3. Run `bin/update` to rebuild and propagate the config to `~/.config/mcpu/config.json`

Common server command patterns:
| Runtime | Command pattern |
|---------|----------------|
| npm/npx | `"command": "npx", "args": ["-y", "@scope/mcp-server"]` |
| Python/uv | `"command": "uvx", "args": ["mcp-server-pkg"]` |
| Nix | `"command": "nix", "args": ["shell", "nixpkgs#uv", "--command", "uvx", "mcp-server-pkg"]` |

To **disable** a server without removing it, add `"enabled": false` to its entry.

The mcpu config is propagated to `~/.config/mcpu/` via `xdg.configFile` in `modules/home-manager/cli.nix`.

## How to Test Changes

1. **Quick syntax check** (fast, no build):
   ```bash
   nix flake check
   ```

2. **Build VM** (full system test without installing):
   ```bash
   bin/test-nixos-vm
   ```

3. **Apply to orbiter** (deploy to live machine):
   ```bash
   bin/update
   ```

## Module Conventions

- All shared modules use `lib.mkDefault` for values so hosts can override them
- Host-specific overrides go in the host's `configuration.nix`, never in shared modules
- Custom NixOS modules use the `noelbautista91` namespace (e.g., `noelbautista91.services.custom.nordvpn`)
- Custom options use the `my` namespace (e.g., `my.hardware.gpu`, `my.user.name`)
- Never import `home-manager/home.nix` or `home-manager/plasma.nix` — those files no longer exist; use `modules/home-manager` instead
- The `gui.nix` module requires `plasma-manager` flake input, which is wired through host flake-modules

## Documentation Rule

- Whenever you create a new `.nix` module file, you **must** update the repo structure table in this file to document its purpose. Undocumented modules are a maintenance hazard.

## What NOT to Do

- Do NOT run `nix flake update` directly — use `update-lockfile`
- Do NOT edit `flake.lock` manually
- Do NOT create files in `nixos-config/` or `home-manager/` — those directories no longer exist
- Do NOT add host-specific packages to shared modules — add them to the host's own `configuration.nix`
- Do NOT add aliases or PATH entries to `.zshrc` or `.gitconfig` — those are now managed by Nix