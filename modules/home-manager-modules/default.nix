# this folder container modules that are for home manager only
{...}: {
  imports = [
    ./flipperzero.nix
    ./i18n.nix
    ./openssh.nix
  ];
}
