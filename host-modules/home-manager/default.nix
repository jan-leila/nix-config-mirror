# modules in this folder are to adapt home manager modules defined in `home-modules` to any nix module configs that they need to set
{...}: {
  imports = [
    ./flipperzero.nix
    ./i18n.nix
  ];
}
