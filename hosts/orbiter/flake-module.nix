{ inputs, ... }:

{
  flake.nixosConfigurations.orbiter = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.noelbautista91 = {
            imports = [
              inputs.plasma-manager.homeModules.plasma-manager
              ../../modules/home-manager
              ../../modules/home-manager/gui.nix
            ];
          };
          extraSpecialArgs = { inherit inputs; };
        };
      }
      ./configuration.nix
    ];
  };
}