# this folder container modules that are for nixos only
{...}: {
  imports = [
    ./home-manager
    ./system.nix
    ./hardware.nix
    ./users.nix
    ./desktop.nix
    ./ssh.nix
    ./i18n.nix
    ./sync.nix
    ./impermanence.nix
    ./disko.nix
    ./ollama.nix
    ./server
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];
}
