{
  lib,
  config,
  ...
}: {
  imports = [./leyla ./ester ./eve];

  users.mutableUsers = false;

  home-manager.users = import ./home.nix {
    lib = lib;
    config = config;
  };
}
