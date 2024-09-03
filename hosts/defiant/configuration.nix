# server nas
{ config, pkgs, inputs, ... }:
{
  imports =
    [
      inputs.home-manager.nixosModules.default
      inputs.sops-nix.nixosModules.sops

      ./hardware-configuration.nix
      
      ../../enviroments/server
    ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/leyla/.config/sops/age/keys.txt";

  users.leyla.isNormalUser = true;
  users.ester.isNormalUser = false;
  users.eve.isNormalUser = false;


  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking.hostName = "defiant"; # Define your hostname.

  nixpkgs.config.allowUnfree = true;

  # temp enable desktop enviroment for setup
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.xterm.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}