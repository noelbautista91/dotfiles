# TODO

## Extract machine-specific values from shared modules

The following values in `modules/home-manager/gui.nix` are hardcoded to orbiter-specific hardware/settings and should eventually be made configurable per-host via custom options:

- `kwinrc.Xwayland.Scale = 1.7` (display scale factor, line ~263)
- `kcminputrc."Libinput/13364/53313/Keychron Keychron M3 mini 4K".NaturalScroll` (mouse device, line ~248)
- `kcminputrc."Libinput/13364/53313/Keychron M3 mini 4K".NaturalScroll` (keyboard device, line ~249)

These should be moved to host-level config or wrapped in custom `my` options so other machines can override them.
