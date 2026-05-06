{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = lib.mkDefault true;

  networking.firewall = {
    enable = lib.mkDefault true;
    allowedTCPPorts = lib.mkDefault [ 443 8765 ];
    allowedUDPPorts = lib.mkDefault [ 1194 51820 41641 ];
  };

  networking.stevenblack = {
    enable = lib.mkDefault false;
  };

  services.resolved = lib.mkDefault { enable = false; };
  services.kresd = {
    enable = lib.mkDefault true;
    extraConfig = lib.mkDefault "";
  };
  environment.etc."resolv.conf" = lib.mkDefault {
    mode = "0644";
    text = ''
      nameserver ::1
    '';
  };
}