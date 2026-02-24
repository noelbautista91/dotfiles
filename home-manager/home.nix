{ config, pkgs, lib, ... }:
let
  onePassPath = "~/.1password/agent.sock";
in {
  imports = [<plasma-manager/modules>];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "noelbautista91";
  home.homeDirectory = "/home/noelbautista91";

  # home.file.".ssh/authorized_keys" = {
  #   # Define the content of the authorized_keys file.
  #   # Each public key should be on a new line.
  #   text = ''
  #     ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNg8s3WVUpuUM2px6d5JgSfgI+tcjRFfcXXbJ2iZzqC
  #   '';
  # };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.vlc
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/noelbautista91/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    EDITOR = "nvim";
    DOCKER_BUILDKIT = "1";
  };

  nixpkgs.config.allowUnfree= true;

  programs = {
    home-manager = {
      enable = true;
    };
    neovim = {
      enable = true;
    };
    qutebrowser = {
      enable = true;
    };
    git = {
      enable = true;
      settings = {
        user = {
	  name = "noelbautista91";
          email = "noel@noynoy.org";
        };
	gpg = {
	  format = "ssh";
	};
	signing = {
	  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcOxXQPaZT+Cz7ZrDMEHc40Ba9HCyUWmvwVKJVaz/j4";
	  signByDefault = true;
	};
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
	theme = "robbyrussell";
	plugins = [
	  "git"
	  "1password"
	  "dotenv"
	  "ssh"
	  "direnv"
	];
      };
    };
    ssh = {
      enable = true;
      # enableDefaultConfig = false;
      extraConfig = ''
        Host *
          IdentityAgent ${onePassPath}
      '';
    };
    ghostty = {
      enable = true;
      package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      enableZshIntegration = true;
    };
    tmux = {
      enable = true;
    };
    distrobox = {
      enable = true;
    };
   # plasma.source = substituteAll ( (import ./plasma.nix { inherit lib; }) );
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };

  # services.nordvpn = {
  #   enable = true;
  #   users = [ "noelbautista91" ];  # Users to add to nordvpn group
  # };
}
