# Tailscale mesh VPN — enables daemon, nftables firewall mode, and trusted interface
{ config, lib, pkgs, ... }:

{
  services.tailscale = {
    enable = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
  };

  # Use nftables mode to avoid conflicts with NixOS's nftables-based firewall
  systemd.services.tailscaled.environment = {
    TS_DEBUG_FIREWALL_MODE = "nftables";
  };

  # Allow tailnet traffic through the firewall
  networking.firewall.trustedInterfaces = lib.mkDefault [ "tailscale0" ];

  # Required for exit node / subnet routing functionality
  networking.firewall.checkReversePath = lib.mkDefault "loose";
}