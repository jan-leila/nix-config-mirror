{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      forEachPkgs = lambda: forEachSystem (system: lambda nixpkgs.legacyPackages.${system});
    in
    {
      packages = forEachPkgs (pkgs: import ./pkgs { inherit pkgs; });

      nixosConfigurations = {
      	# Leyla Laptop
        horizon = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ 
            ./hosts/horizon/configuration.nix
            inputs.home-manager.nixosModules.default
            nixos-hardware.nixosModules.framework-11th-gen-intel
          ];
        };
        # Leyla Desktop
        twilight = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ 
            ./hosts/twilight/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        # NAS Service
        defiant = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inpits; }
          modules = [
            ./hosts/defiant/configuration.nix
          ]
        };
      };
    };
}
