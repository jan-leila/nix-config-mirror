{
  description = "Nixos config flake";

  inputs = {
    # base packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # secret encryption
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # self hosted repo of secrets file to further protect files in case of future encryption vunrabilities
    secrets = {
      url = "git+https://git.jan-leila.com/jan-leila/nix-config-secrets?ref=main";
      flake = false;
    };

    # disk configurations
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # users home directories
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox-addons = {
    #   url = "gitlab.com:rycee/nur-expressions?dir=pkgs/firefox-addons";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # vscode extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pregenerated hardware configurations
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    nixos-hardware,
    home-manager,
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
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
          ./hosts/horizon/configuration.nix
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ];
      };
      # Leyla Desktop
      twilight = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
          ./hosts/twilight/configuration.nix
        ];
      };
      # NAS Service
      defiant = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
          ./hosts/defiant/disko-config.nix
          ./hosts/defiant/configuration.nix
        ];
      };
    };
  };
}
