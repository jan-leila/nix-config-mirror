{
  lib,
  config,
  ...
}: let
  home-users = lib.attrsets.mapAttrsToList (_: user: user) config.home-manager.users;
in {
  hardware.flipperzero.enable = lib.lists.any (home-user: home-user.hardware.flipperzero.enable) home-users;
}
