{ lib, config, pkgs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports =[
    ./packages.nix
  ];

  options.users.leyla = {
    isNormalUser = lib.mkEnableOption "create usable leyla user";
    hasPiperMouse = lib.mkEnableOption "install programs for managing piper supported mouses";
    hasOpenRGBHardware = lib.mkEnableOption "install programs for managing openRGB supported hardware";
    hasViaKeyboard = lib.mkEnableOption "install programs for managing via supported keyboards";
    hasGPU = lib.mkEnableOption "installs gpu intensive programs";
  };

  config = {
    sops.secrets = lib.mkIf cfg.isNormalUser {
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
        if cfg.isNormalUser then {
          isNormalUser = true;
          extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];

          hashedPasswordFile = config.sops.secrets."passwords/leyla".path;
        } else {
          isSystemUser = true;
        }
      )
    ];

    home-manager.users.leyla = lib.mkIf cfg.isNormalUser (import ./home.nix);
  };
}