{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };

  boot.loader.grub.enable = false;

  networking.hostName = lib.mkForce "test-vm";

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 2;
      diskSize = 20480;
    };
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
        proto = "tcp";
      }
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  system.stateVersion = "25.11";

  users.users.root = {
    initialPassword = "";
  };

  users.users.${config.my.user.name} = {
    initialPassword = "";
    extraGroups = [ "wheel" ];
  };

  hardware.enableRedistributableFirmware = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;
}