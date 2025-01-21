{
  lib,
  config,
  ...
}: let
  host = config.host;
in {
  users = {
    users = {
      leyla = {
        name = lib.mkForce host.users.leyla.name;
        home = lib.mkForce "/home/${host.users.leyla.name}";
      };
    };
  };
}
