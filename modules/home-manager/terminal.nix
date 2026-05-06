{ config, lib, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      copy-on-select = "clipboard";
    };
  };
}