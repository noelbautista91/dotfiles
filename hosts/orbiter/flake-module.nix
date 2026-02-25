{ inputs, lib, config, pkgs, ... }:

let
  username = "noelbautista91";
  hostname = "orbiter";
in
{
  nixosConfigurations = {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./configuration.nix
        ({ pkgs, ... }: {
          home-manager.users.${username} = import ../../home-manager/home.nix {
            inherit pkgs;
            username = username;
            homeDirectory = "/home/${username}";
            stateVersion = "25.11";
          };
        })
      ];
    };
  };

  homeConfigurations = {
    "${username}@${hostname}" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
      modules = [
        ../../home-manager/home.nix
      ];
    };
  };
}
