{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.users.ester;
in {
  options.users.ester = {
    isFullUser = lib.mkEnableOption "ester";
  };

  config = {
    sops.secrets = lib.mkIf cfg.isFullUser {
      "passwords/ester" = {
        neededForUsers = true;
        # sopsFile = ../secrets.yaml;
      };
    };

    users.users.ester = (
      if cfg.isFullUser
      then {
        isNormalUser = true;
        extraGroups = ["networkmanager" "users"];

        hashedPasswordFile = config.sops.secrets."passwords/ester".path;

        packages = with pkgs; [
          firefox
          bitwarden
          discord
        ];
      }
      else {
        isSystemUser = true;
      }
    );
  };
}
