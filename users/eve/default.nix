{ lib, config, pkgs, ... }:
let
  cfg = config.users.eve;
in
{
  options.users.eve = {
    isNormalUser = lib.mkEnableOption "eve";
  };

  config = {
    sops.secrets = lib.mkIf cfg.isNormalUser {
      "passwords/eve" = {
        neededForUsers = true;
        # sopsFile = ../secrets.yaml;
      };
    };

    users.groups.eve = {};

    users.users.eve = lib.mkMerge [
      {
        uid = 1002;
        description = "Eve";
        group = "eve";
      }

      (
        if cfg.isNormalUser then {
          isNormalUser = true;
          extraGroups = [ "networkmanager" ];

          hashedPasswordFile = config.sops.secrets."passwords/eve".path;

          packages = with pkgs; [
            firefox
            bitwarden
            discord
            makemkv
            signal-desktop
          ];
        } else {
          isSystemUser = true;
        }
      )
    ];
  };
}