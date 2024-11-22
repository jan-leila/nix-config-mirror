{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.nixos.users.ester;
in {
  options.nixos.users.ester = {
    isDesktopUser = lib.mkEnableOption "install applications intended for desktop use";
  };

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
