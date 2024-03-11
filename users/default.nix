{ inputs, ... }:
{
  imports = [ ./leyla ./ester ./eve ./remote ];

  users.mutableUsers = false;

  home-manager.extraSpecialArgs = { inherit inputs; };
}