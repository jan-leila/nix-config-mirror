{ lib, config, pkgs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports =[
    ./packages.nix
  ];

  options.users.leyla = {
    isFullUser = lib.mkEnableOption "create usable leyla user";
    isThinUser = lib.mkEnableOption "create usable user but witohut user applications";
    hasPiperMouse = lib.mkEnableOption "install programs for managing piper supported mouses";
    hasOpenRGBHardware = lib.mkEnableOption "install programs for managing openRGB supported hardware";
    hasViaKeyboard = lib.mkEnableOption "install programs for managing via supported keyboards";
    hasGPU = lib.mkEnableOption "installs gpu intensive programs";
  };

  config = {
    sops.secrets = lib.mkIf (cfg.isFullUser || cfg.isThinUser) {
      "passwords/leyla" = {
        neededForUsers = true;
        # sopsFile = ../secrets.yaml;
      };
    };

    users.groups.leyla = {};

    users.users.leyla = lib.mkMerge [
      {
        uid = 1000;
        description = "Leyla";
        group = "leyla";
      }

      (
        if (cfg.isFullUser || cfg.isThinUser) then {
          isNormalUser = true;
          extraGroups = lib.mkMerge [
            ["networkmanager" "wheel" "users"]
            (
              lib.mkIf (!cfg.isThinUser) [ "adbusers" ]
            )
          ];

          hashedPasswordFile = config.sops.secrets."passwords/leyla".path;

          openssh = {
            authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHeItmt8TRW43uNcOC+eIurYC7Eunc0V3LGocQqLaYj leyla@horizon"
            ];
          };
        } else {
          isSystemUser = true;
        }
      )
    ];

    # TODO: this should reference the home directory from the user config
    services.openssh.hostKeys = [
      {
        path = "/home/leyla/.ssh/leyla_" + config.networking.hostName + "_ed25519";
        rounds = 100;
        type = "ed25519";
      }
    ];

    home-manager.users.leyla = lib.mkIf (cfg.isFullUser || cfg.isThinUser) (import ./home.nix);
  };
}