{
  lib,
  config,
  ...
}: let
  users = config.host.users;
in {
  leyla = lib.mkIf users.leyla.isNormalUser (import ./leyla);
  eve = lib.mkIf users.eve.isNormalUser (import ./eve);
}
