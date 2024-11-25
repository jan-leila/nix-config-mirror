# this folder container modules that are for nixos only
{...}: {
  imports = [
    ./home-manager
    ./system.nix
    ./hardware.nix
    ./users.nix
    ./desktop.nix
    ./nix-development.nix
    ./i18n.nix
  ];
}
