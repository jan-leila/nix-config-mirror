{
  lib,
  config,
  ...
}: let
  cfg = config.users.leyla;
in {
  imports = [
    ./packages.nix
  ];

  options.users.leyla = {
    isFullUser = lib.mkEnableOption "create usable leyla user";
    isThinUser = lib.mkEnableOption "create usable user but witohut user applications";
    hasGPU = lib.mkEnableOption "installs gpu intensive programs";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    sops.secrets = lib.mkIf (cfg.isFullUser || cfg.isThinUser) {
      "passwords/leyla" = {
        neededForUsers = true;
        sopsFile = ../../secrets/user-passwords.yaml;
      };
    };

    users.users.leyla = (
      if (cfg.isFullUser || cfg.isThinUser)
      then {
        isNormalUser = true;
        extraGroups = lib.mkMerge [
          ["networkmanager" "wheel" "users"]
          (
            lib.mkIf (!cfg.isThinUser) ["adbusers"]
          )
        ];

        hashedPasswordFile = config.sops.secrets."passwords/leyla".path;

        openssh = {
          authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHeItmt8TRW43uNcOC+eIurYC7Eunc0V3LGocQqLaYj leyla@horizon"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBiZkg1c2aaNHiieBX4cEziqvJVj9pcDfzUrKU/mO0I leyla@twilight"
          ];
        };
      }
      else {
        isSystemUser = true;
      }
    );

    # TODO: this should reference the home directory from the user config
    services.openssh.hostKeys = [
      {
        comment = "leyla@" + config.networking.hostName;
        path = "/home/leyla/.ssh/leyla_" + config.networking.hostName + "_ed25519";
        rounds = 100;
        type = "ed25519";
      }
    ];

    home-manager.users.leyla = lib.mkIf (cfg.isFullUser || cfg.isThinUser) (import ./home.nix);
  };
}
