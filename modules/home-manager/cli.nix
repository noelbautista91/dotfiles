{ config, lib, pkgs, ... }:

{
  home.stateVersion = "25.11";

  xdg.configFile."opencode/AGENTS.md" = {
    source = ./../../config/opencode/AGENTS.md;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DOCKER_BUILDKIT = "1";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/Documents/Projects/dotfiles/bin"
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Noel Bautista";
        email = "noel@noynoy.org";
      };
      commit.gpgsign = true;
      gpg = {
        format = "ssh";
        ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      };
      init.defaultBranch = "main";
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
        ui = "auto";
      };
    };
    signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJO7b+YRjNbRqms5s8hC1IHcOxXQPaZT+Cz7ZrDMEHc4";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = {
      vim = "nvim";
      v = "nvim";
      ls = "ls --color=auto";
      ll = "ls -la";
      la = "ls -la";
      del = "rm -rf";
      rm = "rm -I";
      cc = "claude";
      opencode-dev = "nix run /home/noelbautista91/Documents/Projects/opencode";
    };
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
    initContent = ''
      HYPHEN_INSENSITIVE="true"
    '';
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "xterm-256color";
    extraConfig = builtins.readFile ./tmux.conf;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.distrobox = {
    enable = true;
  };
}