{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    chromium
    vlc
  ];
}