# modules in this folder are to adapt home-manager modules configs to nixos-module configs
{...}: {
  imports = [
    ./flipperzero.nix
    ./i18n.nix
    ./openssh.nix
  ];
}
