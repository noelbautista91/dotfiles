{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./boot.nix
    ./desktop.nix
    ./gpu.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./security.nix
    ./services.nix
    ./tailscale.nix
    ./users.nix
    ./virtualization.nix
  ];
}