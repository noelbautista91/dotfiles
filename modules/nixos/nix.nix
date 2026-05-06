{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
      auto-optimise-store = lib.mkDefault true;
      warn-dirty = lib.mkDefault false;
    };

    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    optimise.automatic = lib.mkDefault true;
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  programs.nix-ld.enable = lib.mkDefault true;
}