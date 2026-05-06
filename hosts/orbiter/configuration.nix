{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos
    ./hardware-configuration.nix
    ./nordvpn.nix
  ];

  networking.hostName = "orbiter";
  networking.wireguard.enable = true;

  my.hardware.gpu = {
    enable = true;
    type = "amd";
  };

  environment.systemPackages = with pkgs; [
    llama-cpp-rocm
  ];

  noelbautista91.services.custom.nordvpn.enable = true;

  users.users.${config.my.user.name}.extraGroups = [ "nordvpn" ];

  system.stateVersion = "25.11";
}