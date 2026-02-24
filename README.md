# dotfiles
Feb 2026 Update - We on NixOS now.

## Installation


```
mkdir -p ~/Documents/Projects

cd ~/Documents/Projects

git clone ..

nixos-rebuild switch -I nixos-config=${HOME}/Documents/Projects/dotfiles/nixos-config/configuration.nix --sudo

home-manager -f ${HOME}/Documents/Projects/dotfiles/home-manager/home.nix
```

## TODO
1) There should be no need to run home-manager -f ... switch separately. Updates / Installation should also be done by nixos-rebuild switch command.

2) `pkgs_update` command should run nixos-rebuild ... script.

3) Install xclip so I can use pbcopy / pbpaste aliases in .zshrc

4) neovim should also have lazyvim setup. also our vim configs here should be migrated to use nix style.

5) use this .gitconfig and make sure nix installs that too.

6) nix pkgs should work with both MacOS (darwin) and Linux.
