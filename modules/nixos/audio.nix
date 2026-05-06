{ config, lib, pkgs, ... }:

{
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa = {
      enable = lib.mkDefault true;
      support32Bit = lib.mkDefault true;
    };
    pulse.enable = lib.mkDefault true;
  };

  security.rtkit.enable = lib.mkDefault true;

  hardware.graphics.enable = lib.mkDefault true;
}