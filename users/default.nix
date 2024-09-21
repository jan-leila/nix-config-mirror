{inputs, ...}: {
  imports = [./leyla ./ester ./eve];

  users.mutableUsers = false;

  home-manager.extraSpecialArgs = {inherit inputs;};
}
