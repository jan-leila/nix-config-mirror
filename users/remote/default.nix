{  lib, config, ... }:
let
  cfg = config.users.remote;
in
{
  options.users.remote = {
    isNormalUser = lib.mkEnableOption "remote";
  };

  config.users = {
    groups.remote = {};

    users.remote = lib.mkMerge [
      {
        uid = 2000;
        group = "remote";
      }

      (
        if cfg.isNormalUser then {
          # extraGroups = [ "wheel" ];
          isNormalUser = true;
          openssh.authorizedKeys.keys = [];
        } else {
          isSystemUser = true;
        }
      )
    ];
  };
}