{inputs}: let
  util = (import ./default.nix) {inherit inputs;};
  outputs = inputs.self.outputs;

  lib = inputs.lib;
  lix-module = inputs.lix-module;
  nixpkgs = inputs.nixpkgs;
  home-manager = inputs.home-manager;
  sops-nix = inputs.sops-nix;

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
  forEachSystem = nixpkgs.lib.genAttrs systems;
  pkgsFor = system: nixpkgs.legacyPackages.${system};

  home-manager-shared-modules = [
    ../modules
    ../home-modules
  ];
  home-manager-config = nixpkgs: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {inherit inputs;};
    home-manager.users = import ../homes nixpkgs;
    home-manager.sharedModules = home-manager-shared-modules;
  };
in {
  forEachPkgs = lambda: forEachSystem (system: lambda (pkgsFor system));

  mkUnless = condition: yes: (lib.mkIf (!condition) yes);
  mkIfElse = condition: yes: no:
    lib.mkMerge [
      (lib.mkIf condition yes)
      (lib.mkUnless condition no)
    ];

  mkSystem = host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs util;};
      modules = [
        lix-module.nixosModules.default
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        home-manager-config
        ../modules
        ../host-modules
        ../hosts/${host}
      ];
    };

  mkHome = user: host: system: osConfig:
    home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;
      extraSpecialArgs = {
        inherit inputs util outputs osConfig;
      };
      modules =
        home-manager-shared-modules
        ++ [
          ../homes/${user}
        ];
    };
}
