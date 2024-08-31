# server nas
{ config, pkgs, inputs, ... }:
{
  imports =
    [
      inputs.sops-nix.nixosModules.sops

      ./hardware-configuration.nix
      
      ../../enviroments/server
    ];
}