{ config, lib, pkgs, ... }:

{
  options.my.user.name = lib.mkOption {
    type = lib.types.str;
    default = "noelbautista91";
  };

  config = {
    users.users.${config.my.user.name} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "podman"
      ];
      shell = pkgs.zsh;
      openssh = {
        authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY1CXx+5xIRhXXbJBHvK4U0/X3drE5N0DdagNZ9xxRz noel@noynoy.org"
          ];
        };
      };
    };
  };
}