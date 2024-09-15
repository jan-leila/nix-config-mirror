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
            ["networkmanager" "wheel" "docker" "users"]
            (
              lib.mkIf (!cfg.isThinUser) [ "adbusers" ]
            )
          ];

          hashedPasswordFile = config.sops.secrets."passwords/leyla".path;
        } else {
          isSystemUser = true;
        }
      )
    ];

    home-manager.users.leyla = lib.mkIf (cfg.isFullUser || cfg.isThinUser) (import ./home.nix);
  };
}