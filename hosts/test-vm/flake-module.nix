{ inputs, ... }:

{
  flake.nixosConfigurations.test-vm = inputs.nixpkgs.lib.nixosSystem {
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
              inputs.nixvim.homeModules.nixvim
              ../../modules/home-manager
            ];
          };
          extraSpecialArgs = { inherit inputs; };
        };
      }
      ./default.nix
    ];
  };
}