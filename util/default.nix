{inputs}: let
  util = (import ./default.nix) {inherit inputs;};
  outputs = inputs.self.outputs;

  lib = inputs.lib;
  nixpkgs = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  nix-darwin = inputs.nix-darwin;
  sops-nix = inputs.sops-nix;

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
  forEachSystem = nixpkgs.lib.genAttrs systems;
  pkgsFor = system: nixpkgs.legacyPackages.${system};

  common-modules = [
    ../modules/common-modules
  ];

  home-manager-modules =
    common-modules
    ++ [
      sops-nix.homeManagerModules.sops
      ../modules/home-manager-modules
    ];

  home-manager-config = nixpkgs: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {inherit inputs outputs util;};
    home-manager.users = import ../configurations/home-manager nixpkgs;
    home-manager.sharedModules = home-manager-modules;
  };

  system-modules =
    common-modules
    ++ [
      home-manager-config
      ../modules/system-modules
    ];
in {
  forEachPkgs = lambda: forEachSystem (system: lambda (pkgsFor system));

  mkUnless = condition: yes: (lib.mkIf (!condition) yes);
  mkIfElse = condition: yes: no:
    lib.mkMerge [
      (lib.mkIf condition yes)
      (lib.mkUnless condition no)
    ];

  mkNixosInstaller = host: userKeys:
    nixpkgs.lib.nixosSystem {
      modules = [
        {
          # TODO: authorized keys for all users
        }
        ../configurations/nixos/${host}
      ];
    };

  mkNixosSystem = host:
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs util;};
      modules =
        system-modules
        ++ [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          ../modules/nixos-modules
          ../configurations/nixos/${host}
        ];
    };

  mkDarwinSystem = host:
    nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs outputs util;};
      modules =
        system-modules
        ++ [
          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
          ../modules/darwin-modules
          ../configurations/darwin/${host}
        ];
    };

  mkHome = user: host: system: osConfig:
    home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;
      extraSpecialArgs = {
        inherit inputs util outputs osConfig;
      };
      modules =
        home-manager-modules
        ++ [
          ../configurations/home-manager/${user}
        ];
    };
}
