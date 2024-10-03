{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.home-manager.users.eve;
in {
  config = {
    nixpkgs.config.allowUnfree = true;

    sops.secrets = lib.mkIf cfg.isDesktopUser {
      "passwords/eve" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
    };

    users.users.eve = (
      if cfg.isDesktopUser
      then {
        isNormalUser = true;
        extraGroups = ["networkmanager"];

        hashedPasswordFile = config.sops.secrets."passwords/eve".path;
      }
      else {
        isSystemUser = true;
      }
    );
  };
}
