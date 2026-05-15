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
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFo+eNl0DbBmTYtDRWfgxeuLPxMZp78f99DbVwgahfU"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcOxXQPaZT+Cz7ZrDMEHc40Ba9HCyUWmvwVKJVaz/j4"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxlsP0/V/W2CQj9mocEvKyW9nwwfU5zvfDZAQDNaGl4"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNg8s3WVUpuUM2px6d5JgSfgI+tcjRFfcXXbJ2iZzqC"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeyLX4GGq7daqXWcw1VZKdVFoMukqKe+2JXsXJmVG+1"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBg8wanF/61h6IizynEwyrXwTx3TTt5/37Cz0Ao8Nq+d"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbNZ3ekBk7I9oiaUGZoDNA1Aok1hIkyaaFbb9MCwPHk"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8twDI3F/r+upjVGigX0/93GFhL4pAohWeOYD2clWca"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKO6mSWR0HnKVbDfUOTG2ShbzRwXnawCN63jGNUw7OaA"
          ];
        };
      };
    };
  };
}