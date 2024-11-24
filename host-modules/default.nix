{...}: {
  imports = [
    ./system.nix
    ./hardware.nix
    ./users.nix
    ./desktop.nix
    ./nix-development.nix
    ./home-manager
  ];
}
