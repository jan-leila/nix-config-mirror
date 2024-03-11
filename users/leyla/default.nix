{ lib, config, pkgs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports =[
    ./packages.nix
  ];

  options.users.leyla = {
    isNormalUser = lib.mkEnableOption "leyla";
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
          extraGroups = [ "networkmanager" "wheel" ];

          hashedPasswordFile = config.sops.secrets."passwords/leyla".path;
        } else {
          isSystemUser = true;
        }
      )
    ];
  };
}