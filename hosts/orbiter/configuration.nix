{ inputs, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nordvpn.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

  networking.hostName = "orbiter";

  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  networking.firewall.enable = true;

  environment.etc.hosts.mode = "0644";

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = false;

  services.kresd.enable = true;

  environment.etc."resolv.conf" = {
    mode = "0644";
    text = "nameserver ::1";
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.noelbautista91 = {
    isNormalUser = true;
    description = "Noel Bautista";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "nordvpn"
    ];
    packages = with pkgs; [
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNg8s3WVUpuUM2px6d5JgSfgI+tcjRFfcXXbJ2iZzqC"
    ];
  };

  programs = {
    firefox = {
      enable = true;
    };
    firejail = {
      enable = true;
    };
    nix-ld = {
      enable = true;
    };
    steam = {
      enable = true;
    };
    _1password = {
      enable = true;
    };
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "noelbautista91" ];
    };
    zsh = {
      enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    zsh
    nodejs
    clinfo
    telegram-desktop
    pkgs.kdePackages.kdeconnect-kde
    uv
    dive
    podman-tui
    docker-compose
    pkgs.llama-cpp-rocm
    pkgs.rofi
  ];

  services.openssh.enable = true;
  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "noelbautista91" ];
      Macs = [ "hmac-sha2-512" "hmac-sha2-256" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 8765 ];
  networking.firewall.allowedUDPPorts = [ 1194 51820 41641 ];
  networking.firewall = rec {
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
      { from = 3478; to = 3479; }
    ];
  };

  system.stateVersion = "25.11";
  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  noelbautista91.services.custom.nordvpn.enable = true;

  services.libinput.enable = true;
  services.libinput.mouse.naturalScrolling = true;
}
