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

    # delete your darlings
    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };

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

    # lix in nice ig
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    util = import ./util {inherit inputs;};
    forEachPkgs = util.forEachPkgs;
    mkSystem = util.mkSystem;
    mkHome = util.mkHome;
    # callPackage = nixpkgs.lib.callPackageWith (nixpkgs // {lib = lib;});
    # lib = callPackage ./lib {} // nixpkgs.lib;
  in {
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

    homeConfigurations = nixpkgs.lib.attrsets.mergeAttrsList (
      nixpkgs.lib.attrsets.mapAttrsToList (hostname: system: (
        nixpkgs.lib.attrsets.mapAttrs' (user: _: {
          name = "${user}@${hostname}";
          value = mkHome user hostname system.pkgs.hostPlatform.system system.config;
        })
        system.config.home-manager.users
      ))
      self.nixosConfigurations
    );

    # homeConfigurations = {
    #   "leyla@horizon" = mkHome "leyla" "horizon"; # "x86_64-linux" ./homes/leyla;
    # };

    nixosConfigurations = {
      # Leyla Laptop
      horizon = mkSystem "horizon";
      twilight = mkSystem "twilight";
      defiant = mkSystem "defiant";
    };
  };
}
