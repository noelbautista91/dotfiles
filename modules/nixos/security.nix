{ config, lib, pkgs, ... }:

{
  programs.firefox.enable = lib.mkDefault true;
  programs.firejail.enable = lib.mkDefault true;
  programs.steam.enable = lib.mkDefault true;
  programs.zsh.enable = lib.mkDefault true;
  programs._1password.enable = lib.mkDefault true;
  programs._1password-gui = {
    enable = lib.mkDefault true;
    polkitPolicyOwners = [ "noelbautista91" ];
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "noelbautista91" ];
      Macs = [
        "hmac-sha2-512"
        "hmac-sha2-256"
      ];
    };
  };

  }