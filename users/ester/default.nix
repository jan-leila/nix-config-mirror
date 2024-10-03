{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.home-manager.users.ester;
in {
  config = {
    nixpkgs.config.allowUnfree = true;

    sops.secrets = lib.mkIf cfg.isDesktopUser {
      "passwords/ester" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
    };

    users.users.ester = (
      if cfg.isDesktopUser
      then {
        isNormalUser = true;
        extraGroups = ["networkmanager"];

        hashedPasswordFile = config.sops.secrets."passwords/ester".path;
      }
      else {
        isSystemUser = true;
      }
    );
  };
}
