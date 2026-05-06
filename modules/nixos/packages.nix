{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; lib.mkDefault [
    clinfo
    dive
    docker-compose
    kdeconnect-kde
    nodejs_24
    podman-tui
    telegram-desktop
    uv
  ];
}