# AGENTS.md — Global OpenCode Instructions

## Environment

This machine uses NixOS with flakes. All package management, script execution, and development environments use Nix.

## Running Commands

### Prefer Nix idioms over system packages
Never assume a package is installed on the system. Always use Nix to run tools:

```bash
# Run a package without installing it
nix run nixpkgs#<package> -- <args>

# Run a shell with a package available
nix shell nixpkgs#<package> -c <command>

# Examples
nix run nixpkgs#ripgrep -- --help
nix shell nixpkgs#jq -c "jq '.' file.json"
nix run nixpkgs#python3 -- script.py
```

### Use `nix develop` for adhoc script execution
This repo's flake provides a development shell with Python 3. When writing one-off scripts for file analysis, data transformation, bulk editing, or pattern matching, always use Python — not bash sed/awk.

```bash
# Enter dev shell (has python3 available)
nix develop

# Run a Python script directly
nix develop --command python3 script.py

# Run inline Python
nix develop --command python3 -c "
import json
with open('data.json') as f:
    print(json.load(f))
"
```

### Common Nix commands reference
| Task | Command |
|---|---|
| Check flake syntax | `nix flake check` |
| Build a NixOS config | `nixos-rebuild switch --flake .#<host>` |
| Build a package | `nix build nixpkgs#<package>` |
| Search packages | `nix search nixpkgs <term>` |
| Run a package temporarily | `nix run nixpkgs#<package>` |
| Update flake lockfile | `nix flake update` (but prefer `update-lockfile` from this repo) |
| Enter dev shell | `nix develop` |
| Inspect a store path | `nix path-info nixpkgs#<package>` |

## Writing Code

### Nix documentation
When writing Nix code (modules, flake inputs, overlays, etc.), always include:
- A brief comment at the top of each attribute set or module explaining its purpose
- Comments on any non-obvious `lib.mkDefault` or `lib.mkForce` overrides explaining why the default is being changed
- The `type` and `description` for any custom `lib.mkOption`
- Example comments for complex derivations or `writeShellScriptBin` calls

Example:
```nix
{
  # GPU configuration module — supports AMD, Intel, and NVIDIA
  options.my.hardware.gpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable GPU driver support.";
    };
    type = lib.mkOption {
      type = lib.types.enum [ "amd" "intel" "nvidia" ];
      default = "amd";
      description = "GPU vendor to configure drivers for.";
    };
  };
}
```

### Adhoc scripts must use Python
When you need to write any adhoc script for:
- Analyzing or transforming files
- Generating test data or results
- Pattern-based bulk editing (replacing sed/awk/perl one-liners)
- Data extraction or report generation

**Always write Python 3 scripts** and run them via `nix develop --command python3 <script>`. Do not write complex bash/sed/awk pipelines — they are fragile and hard to maintain. Python scripts are readable, testable, and portable.

Example — bulk find-and-replace across files:
```python
#!/usr/bin/env python3
import re, glob
for path in glob.glob("modules/**/*.nix", recursive=True):
    with open(path) as f:
        content = f.read()
    updated = re.sub(r'lib\.mkDefault "25\.05"', 'lib.mkDefault "25.11"', content)
    if updated != content:
        with open(path, 'w') as f:
            f.write(updated)
        print(f"Updated {path}")
```

Example — JSON analysis:
```python
#!/usr/bin/env python3
import json, sys
data = json.load(sys.stdin)
for pkg in data:
    print(f"{pkg['name']}: {pkg['version']}")
```

### Do not assume packages are installed
Never write commands like `python3 script.py` or `jq '.' file.json` without wrapping them in Nix. The system may not have these packages installed outside the Nix store. Always use:
- `nix run nixpkgs#<package> -- <args>` for one-off runs
- `nix develop --command <cmd>` for scripts that need the dev shell

### File paths in Nix scripts
When writing Nix derivations or scripts that reference files, use relative paths from the repo root or `builtins.pathExists` checks. Never hardcode absolute paths like `/home/username/...` in Nix modules — use `config.home.homeDirectory` or `config.users.users.<name>.home` instead.

## Dotfiles Repo Conventions

When working in this specific dotfiles repo:
- Run `nix flake check` to validate changes before considering work complete
- Use `bin/update` to apply changes (rebuilds from frozen lockfile)
- Use `bin/update-lockfile` to intentionally update package versions
- Never run `nix flake update` directly — always use `update-lockfile`
- Shared modules live in `modules/nixos/`, `modules/home-manager/`, `modules/darwin/`
- Host-specific configs live in `hosts/<hostname>/`
- Never add host-specific packages or settings to shared modules