{ config, lib, pkgs, ... }:

{
  services.desktopManager.plasma6.enable = lib.mkDefault true;
  services.displayManager.sddm = {
    enable = lib.mkDefault true;
    wayland.enable = lib.mkDefault true;
  };

  services.xserver.enable = lib.mkDefault false;

  services.xserver.xkb = {
    layout = lib.mkDefault "us";
  };

  services.printing.enable = lib.mkDefault true;

  fonts.packages = with pkgs; lib.mkDefault [
    (nerdfonts.override { fonts = [ "ALL" ]; })
  ];

  # KDE Connect firewall ports
  networking.firewall.allowedTCPPortRanges = lib.mkDefault [
    { from = 1714; to = 1764; }
  ];
  networking.firewall.allowedUDPPortRanges = lib.mkDefault [
    { from = 1714; to = 1764; }
    { from = 3478; to = 3479; }
  ];
}