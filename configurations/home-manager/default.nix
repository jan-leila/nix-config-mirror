{
  lib,
  config,
  ...
}: let
  users = config.host.users;
in {
  leyla = lib.mkIf users.leyla.isNormalUser (import ./leyla);
  ester = lib.mkIf users.ester.isNormalUser (import ./ester);
  eve = lib.mkIf users.eve.isNormalUser (import ./eve);
}
