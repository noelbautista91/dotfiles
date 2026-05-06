{ config, lib, pkgs, ... }:

{
  virtualisation = {
    containers.enable = lib.mkDefault true;

    podman = {
      enable = lib.mkDefault true;
      dockerCompat = lib.mkDefault true;
      defaultNetwork.settings.dns_enabled = lib.mkDefault true;
    };
  };
}