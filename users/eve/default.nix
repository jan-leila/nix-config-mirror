{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.users.eve;
in {
  options.users.eve = {
    isFullUser = lib.mkEnableOption "eve";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    sops.secrets = lib.mkIf cfg.isFullUser {
      "passwords/eve" = {
        neededForUsers = true;
        sopsFile = ../../secrets/user-passwords.yaml;
      };
    };

    users.users.eve = (
      if cfg.isFullUser
      then {
        isNormalUser = true;
        extraGroups = ["networkmanager"];

        hashedPasswordFile = config.sops.secrets."passwords/eve".path;

        packages = with pkgs; [
          firefox
          bitwarden
          discord
          makemkv
          signal-desktop
        ];
      }
      else {
        isSystemUser = true;
      }
    );
  };
}
