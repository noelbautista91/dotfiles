{ config, lib, pkgs, ... }:

{
  programs.firefox.enable = lib.mkDefault true;
  programs.firejail.enable = lib.mkDefault true;
  programs.steam.enable = lib.mkDefault true;
  programs.zsh.enable = lib.mkDefault true;
  programs._1password.enable = lib.mkDefault true;
  programs._1password-gui = {
    enable = lib.mkDefault true;
    polkitPolicyOwners = [ config.my.user.name ];
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ config.my.user.name ];
      Macs = [
        "hmac-sha2-512"
        "hmac-sha2-256"
      ];
    };
  };

  }