{inputs}: let
  util = (import ./default.nix) {inherit inputs;};
  outputs = inputs.self.outputs;

  lib = inputs.lib;
  lix-module = inputs.lix-module;
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
    lix-module.nixosModules.default
    ../modules/common-modules
  ];

  home-manager-modules =
    common-modules
    ++ [
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
      ../modules/system-modules
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
      home-manager-config
    ];
in {
  forEachPkgs = lambda: forEachSystem (system: lambda (pkgsFor system));

  mkUnless = condition: yes: (lib.mkIf (!condition) yes);
  mkIfElse = condition: yes: no:
    lib.mkMerge [
      (lib.mkIf condition yes)
      (lib.mkUnless condition no)
    ];

  mkNixosSystem = host:
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs util;};
      modules =
        system-modules
        ++ [
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
