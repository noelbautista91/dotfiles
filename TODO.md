# TODO

## Extract machine-specific values from shared modules

The following values in `modules/home-manager/gui.nix` are hardcoded to orbiter-specific hardware/settings and should eventually be made configurable per-host via custom options:

- `kwinrc.Xwayland.Scale = 1.7` (display scale factor, line ~263)
- `kcminputrc."Libinput/13364/53313/Keychron Keychron M3 mini 4K".NaturalScroll` (mouse device, line ~248)
- `kcminputrc."Libinput/13364/53313/Keychron M3 mini 4K".NaturalScroll` (keyboard device, line ~249)

These should be moved to host-level config or wrapped in custom `my` options so other machines can override them.

## Fix memory and playwright MCP servers with mcpu

Both `memory` and `playwright` MCP servers fail with `MCP error -32000: Connection closed` when mcpu tries to connect to them. Other servers (chroma, beads, nixos) work fine.

- **memory server**: Prints `Knowledge Graph MCP Server running on stdio` to stdout before the JSON-RPC response. This non-JSON line likely breaks mcpu's JSON parser. Fix: wrap in a script that filters non-JSON lines from stdout, or file an issue upstream.
- **playwright server**: Outputs clean JSON-RPC with no extra lines, yet still fails with the same "Connection closed" error. Root cause unclear — may be a mcpu bug. Investigate further or file an issue at https://github.com/jchip/mcpu.

Related files: `config/mcpu/config.json`, `.opencode/opencode.jsonc`
