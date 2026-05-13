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

## db-mcp — Persistent Memory

db-mcp (via `db-mcp` MCP server in mcpu) is your long-term memory, backed by a
local SQLite database. Use it proactively — do not wait for the user to ask.

The `db-mcp` server is configured with `--tool-filter codemode`, which reduces
the tool surface to a single sandboxed JS execution tool (`codemode_run`) plus
resources. This means you interact with the database through `codemode_run`
calls that execute JavaScript against the SQLite database, rather than calling
individual SQL tools directly.

### Quick reference

| Action | How |
|---|---|
| List tables | `codemode_run` with `SELECT name FROM sqlite_master WHERE type='table'` |
| Describe table | `codemode_run` with `PRAGMA table_info(<table>)` |
| Create table | `codemode_run` with `CREATE TABLE IF NOT EXISTS <table> (...)` |
| Insert row | `codemode_run` with `INSERT INTO <table> (...) VALUES (...)` |
| Query rows | `codemode_run` with `SELECT ... FROM <table> WHERE ...` |
| Update row | `codemode_run` with `UPDATE <table> SET ... WHERE ...` |
| Delete row | `codemode_run` with `DELETE FROM <table> WHERE ...` |
| Full-text search | `codemode_run` with `SELECT ... FROM <table> WHERE <column> LIKE '%<term>%'` or FTS5 |
| View schema | Use resource `sqlite://schema` |

### Tables

Namespaced by project (repo directory name, lowercase). Create tables on first
write if they don't exist.

| Table | Purpose | Schema |
|---|---|---|
| `<project>_decisions` | Architectural choices, tradeoffs, rationale | `id TEXT PRIMARY KEY, date TEXT, category TEXT, module TEXT, content TEXT, why TEXT` |
| `<project>_fixes` | Bugs resolved — symptom, cause, fix | `id TEXT PRIMARY KEY, date TEXT, area TEXT, symptom TEXT, cause TEXT, fix TEXT` |
| `<project>_preferences` | Project-specific style/workflow preferences | `id TEXT PRIMARY KEY, date TEXT, topic TEXT, preference TEXT, rationale TEXT` |
| `<project>_context` | Conventions, gotchas, structural facts | `id TEXT PRIMARY KEY, date TEXT, area TEXT, topic TEXT, fact TEXT` |
| `global_preferences` | Preferences applying across all projects | `id TEXT PRIMARY KEY, date TEXT, topic TEXT, preference TEXT, rationale TEXT` |

ID format conventions:
- decisions: `decision_<scope>_<topic>`
- fixes: `fix_<area>_<keyword>`
- preferences: `pref_<topic>`
- context: `ctx_<area>_<topic>`

### Creating tables

Before first write, create the table if it doesn't exist:

```
codemode_run with:
CREATE TABLE IF NOT EXISTS <project>_decisions (
  id TEXT PRIMARY KEY,
  date TEXT,
  category TEXT,
  module TEXT,
  content TEXT,
  why TEXT
)
```

### Document format

Each row = one atomic fact. The `content` or `fact` column holds the
declarative statement. The `why` column provides context on why it matters.

### Query triggers (always)

- Before debugging an error → query `<project>_fixes`
- Before architectural/design choices → query `<project>_decisions`
- Before style or formatting decisions → query `<project>_preferences` and `global_preferences`
- When unfamiliar with a project area → query `<project>_context`

### Write triggers (always)

- After resolving a non-obvious bug → `<project>_fixes`
- After making a design decision → `<project>_decisions`
- After learning a user preference → `<project>_preferences` or `global_preferences`
- After discovering a convention or gotcha → `<project>_context`

Before writing to `decisions` or `fixes`: query first to check for duplicates.
Use a SELECT to find existing rows with similar IDs or content. If similar
exists, use UPDATE instead of INSERT.

### Hygiene

- One fact per row, not compound knowledge dumps
- No ephemeral state (currently-open files, temp decisions)
- No secrets (tokens, keys, passwords)
- Prune stale rows when you find them during queries (DELETE or UPDATE)

## Dotfiles Repo Conventions

When working in this specific dotfiles repo:
- Run `nix flake check` to validate changes before considering work complete
- Use `bin/update` to apply changes (rebuilds from frozen lockfile)
- Use `bin/update-lockfile` to intentionally update package versions
- Never run `nix flake update` directly — always use `update-lockfile`
- Shared modules live in `modules/nixos/`, `modules/home-manager/`, `modules/darwin/`
- Host-specific configs live in `hosts/<hostname>/`
- Never add host-specific packages or settings to shared modules