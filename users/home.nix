{
  lib,
  config,
  ...
}: {
  leyla = lib.mkIf (config.nixos.users.leyla.isDesktopUser || config.nixos.users.leyla.isTerminalUser) (import ./leyla/home.nix);
  ester = lib.mkIf config.nixos.users.ester.isDesktopUser (import ./ester/home.nix);
  eve = lib.mkIf config.nixos.users.eve.isDesktopUser (import ./eve/home.nix);
}
