{ config, lib, pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./editors.nix
    ./browsers.nix
    ./terminal.nix
    ./packages.nix
    ./rofi.nix
  ];
}