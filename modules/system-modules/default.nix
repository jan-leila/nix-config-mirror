# this folder container modules that are for nixos and darwin
{...}: {
  imports = [
    ./home-manager
    ./system.nix
    ./nix-development.nix
    ./users.nix
  ];
}
