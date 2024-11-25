{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  options.host.nix-development.enable = lib.mkEnableOption "should desktop configuration be enabled";

  config = lib.mkMerge [
    {
      host.nix-development.enable = lib.mkDefault true;
    }
    (lib.mkIf config.host.nix-development.enable {
      nix = {
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      };
      environment.systemPackages = with pkgs; [
        # nix language server
        nil
        # nix formatter
        alejandra
      ];
    })
  ];
}
