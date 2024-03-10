{ lib, config, pkgs, ... }:
let
  cfg = config.users.ester;
in
{
  options.users.ester = {
    isNormalUser = lib.mkEnableOption "ester";
  };

  config = {
    sops.secrets = lib.mkIf cfg.isNormalUser {
      "passwords/ester" = {
        neededForUsers = true;
        # sopsFile = ../secrets.yaml;
      };
    };

    users.groups.ester = {};

    users.users.ester = lib.mkMerge [
      {
        uid = 1001;
        description = "Ester";
        group = "ester";
      }

      (
        if cfg.isNormalUser then {
          isNormalUser = true;
          extraGroups = [ "networkmanager" ];

          hashedPasswordFile = config.sops.secrets."passwords/ester".path;

          packages = with pkgs; [
            firefox
            bitwarden
            discord
          ];
        } else {
          isSystemUser = true;
        }
      )
    ];
  };
}