{inputs, ...}: {
  imports = [./leyla ./ester ./eve];

  users.mutableUsers = false;

  home-manager.users = import ./home.nix;
}
