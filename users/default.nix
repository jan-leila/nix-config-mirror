{inputs, ...}: {
  imports = [./leyla ./ester ./eve];

  users.mutableUsers = false;

  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.users = import ./home.nix;
}
