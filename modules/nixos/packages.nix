{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; lib.mkDefault [
    clinfo
    dive
    docker-compose
    kdeconnect-kde
    nodejs
    podman-tui
    rofi
    telegram-desktop
    uv
    zsh
  ];
}