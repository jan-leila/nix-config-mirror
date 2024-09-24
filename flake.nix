{
  description = "Nixos config flake";

  inputs = {
    # base packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # encrypt files that contain secrets that I would like to not encrypt
    sops-nix.url = "github:Mic92/sops-nix";

    secrets = {
      url = "git+https://git.jan-leila.com/jan-leila/nix-config-secrets?ref=main";
      flake = false;
    };

    # declairtive disk configuration
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # managment per user
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # repo of hardware configs for prebuilt systems
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # vscode extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    nixos-hardware,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    forEachPkgs = lambda: forEachSystem (system: lambda nixpkgs.legacyPackages.${system});
  in {
    packages = forEachPkgs (pkgs: import ./pkgs {inherit pkgs;});

    nixosConfigurations = {
      # Leyla Laptop
      horizon = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/horizon/configuration.nix
          inputs.home-manager.nixosModules.default
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ];
      };
      # Leyla Desktop
      twilight = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/twilight/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      # NAS Service
      defiant = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          disko.nixosModules.disko
          ./hosts/defiant/disko-config.nix
          ./hosts/defiant/configuration.nix
        ];
      };
    };
  };
}
