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

    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };

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

    flake-compat = {
      url = "github:edolstra/flake-compat";
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    disko,
    # impermanence,
    nixos-hardware,
    home-manager,
    lix-module,
    ...
  } @ inputs: let
    home-manager-config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {inherit inputs;};
    };
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    forEachPkgs = lambda: forEachSystem (system: lambda nixpkgs.legacyPackages.${system});

    callPackage = nixpkgs.lib.callPackageWith (nixpkgs // {lib = lib;});
    lib = callPackage ./util {} // nixpkgs.lib;
  in {
    packages = forEachPkgs (import ./pkgs);

    formatter = forEachPkgs (pkgs: pkgs.alejandra);

    devShells = forEachPkgs (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          git
          sops
          alejandra
          nix-inspect
          nixos-anywhere
        ];

        SOPS_AGE_KEY_DIRECTORY = import ./const/sops_age_key_directory.nix;

        shellHook = ''
          git config core.hooksPath .hooks
        '';
      };
    });

    nixosConfigurations = {
      # Leyla Laptop
      horizon = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs lib;};
        modules = [
          lix-module.nixosModules.default
          ./overlays
          home-manager.nixosModules.home-manager
          home-manager-config
          ./hosts/horizon/configuration.nix
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ];
      };
      # Leyla Desktop
      twilight = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs lib;};
        modules = [
          lix-module.nixosModules.default
          ./overlays
          home-manager.nixosModules.home-manager
          home-manager-config
          ./hosts/twilight/configuration.nix
        ];
      };
      # NAS Service
      defiant = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs lib;};
        modules = [
          lix-module.nixosModules.default
          ./overlays
          # impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          home-manager-config
          ./hosts/defiant/disko-config.nix
          ./hosts/defiant/configuration.nix
        ];
      };
    };
  };
}
