{...}: {
  imports = [
    ./system.nix
    ./hardware.nix
    ./users.nix
    ./desktop.nix
    ./nix-development.nix
    ./i18n.nix
    ./home-manager
  ];
}
