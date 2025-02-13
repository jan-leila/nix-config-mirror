{
  description = "Nixos config flake";

  inputs = {
    # base packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # TODO: figure out why things fail to build with lix
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/stable.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # secret encryption
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # self hosted repo of secrets file to further protect files in case of future encryption vulnerabilities
    secrets = {
      url = "git+ssh://git@git.jan-leila.com/jan-leila/nix-config-secrets.git";
      flake = false;
    };

    # disk configurations
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # delete your darlings
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # users home directories
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # vscode extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pregenerated hardware configurations
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # this is just here so that we have a lock on it for our dev shells
    flake-compat = {
      url = "github:edolstra/flake-compat";
    };
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
    home-manager,
    impermanence,
    ...
  } @ inputs: let
    util = import ./util {inherit inputs;};
    forEachPkgs = util.forEachPkgs;

    mkNixosInstaller = util.mkNixosInstaller;
    mkNixosSystem = util.mkNixosSystem;
    mkDarwinSystem = util.mkDarwinSystem;
    mkHome = util.mkHome;

    installerSystems = {
      basic = mkNixosInstaller "basic" [];
    };

    nixosSystems = {
      horizon = mkNixosSystem "horizon";
      twilight = mkNixosSystem "twilight";
      defiant = mkNixosSystem "defiant";
    };

    darwinSystems = {
      hesperium = mkDarwinSystem "hesperium";
    };

    homeSystems = {
      # stand alone home manager configurations here:
      # name = mkHome "name"
    };

    systemsHomes = nixpkgs.lib.attrsets.mergeAttrsList (
      nixpkgs.lib.attrsets.mapAttrsToList (hostname: system: (
        nixpkgs.lib.attrsets.mapAttrs' (user: _: {
          name = "${user}@${hostname}";
          value = mkHome user hostname system.pkgs.hostPlatform.system system.config;
        })
        system.config.home-manager.users
      ))
      (nixosSystems // darwinSystems)
    );

    homeConfigurations =
      systemsHomes
      // homeSystems;
  in {
    formatter = forEachPkgs (pkgs: pkgs.alejandra);

    # templates = import ./templates;

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

    installerConfigurations = installerSystems;

    nixosConfigurations = nixosSystems;

    darwinConfigurations = darwinSystems;

    homeConfigurations = homeConfigurations;
  };
}
