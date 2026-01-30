{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nordvpn-flake.url = "github:connerohnesorge/nordvpn-flake";
  };

  outputs = { nixpkgs, nordvpn-flake, ... }: {
    nixosConfigurations.noelbautista91 = nixpkgs.lib.nixosSystem {
      modules = [
        nordvpn-flake.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
