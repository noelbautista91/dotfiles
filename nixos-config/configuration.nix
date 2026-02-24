# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  # Import the unstable channel (replace the path/URL with your actual tarball)
  unstableTarball = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  };
  unstable = import unstableTarball {
    config = config.nixpkgs.config;
  };
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nordvpn.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
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

  networking.hostName = "orbiter"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  environment.etc.hosts.mode = "0644";
  # networking.hosts = {
  #   "100.121.71.164" = [
  #     "orbiter.nord"
  #     "orbiter"
  #   ];
  #   "100.112.23.245" = [
  #     "iphone16"
  #     "iphone16.nord"
  #   ];
  #   "100.103.203.82" = [
  #     "compass"
  #     "compass.nord"
  #   ];
  #   "100.119.104.171" = [
  #     "rpi"
  #     "rpi.nord"
  #   ];
  # };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  services.kresd.enable = true;

  # services.resolved.enable = true;

  environment.etc."resolv.conf" = {
    mode = "0644";
    text = "nameserver ::1";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
    #  thunderbird
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNg8s3WVUpuUM2px6d5JgSfgI+tcjRFfcXXbJ2iZzqC"
    ];
  };

  # Install firefox.
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
    # the below only works globally, not per-user install
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: {
    inherit unstable;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    zsh
    nodejs
    clinfo
    telegram-desktop
    pkgs.kdePackages.kdeconnect-kde
    uv
    dive
    podman-tui
    docker-compose
    unstable.llama-cpp-rocm
    pkgs.rofi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 443 8765 ];
  networking.firewall.allowedUDPPorts = [ 1194 51820 41641 ];
  networking.firewall = rec {
    allowedTCPPortRanges = [ 
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [ 
      { from = 1714; to = 1764; }
      { from = 3478; to = 3479; } # meshnet p2p https://github.com/NordSecurity/nordvpn-linux/issues/18
    ];
  };
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };
  noelbautista91.services.custom.nordvpn.enable = true;
  services.libinput.enable = true;
  services.libinput.mouse.naturalScrolling = true;
}
