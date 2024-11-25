# this folder is for modules that are common between nixos, home-manager, and darwin
{...}: {
  imports = [
    ./overlays
    ./pkgs
  ];
}
