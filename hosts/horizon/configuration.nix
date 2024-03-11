# leyla laptop
{ config, pkgs, inputs, ... }:
{
  imports =
    [
      inputs.home-manager.nixosModules.default
      inputs.sops-nix.nixosModules.sops

      ./hardware-configuration.nix
      
      ../../enviroments/client
    ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/leyla/.config/sops/age/keys.txt";

  users.leyla.isNormalUser = true;
  users.ester.isNormalUser = true;
  users.eve.isNormalUser = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.kernelModules = [ "sg" ];

  networking.hostName = "horizon"; # Define your hostname.

  # enabled virtualisation for docker
  # virtualisation.docker.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  nixpkgs.overlays = [
    (self: super: {
      # idea is too out of date for android gradle things
      jetbrains = {
        jdk = super.jdk17;
        idea-community = super.jetbrains.idea-community.overrideAttrs (oldAttrs: rec {
          version = "2023.3.3";
          name = "idea-community-${version}";
          src = super.fetchurl {
            sha256 = "sha256-3BI97Tx+3onnzT1NXkb62pa4dj9kjNDNvFt9biYgP9I=";
            url = "https://download.jetbrains.com/idea/ideaIC-${version}.tar.gz";
          };
        });
      };
      # ui is broken on 1.84
      vscodium = super.vscodium.overrideAttrs (oldAttrs: rec {
        version = "1.85.2.24019";
        src = super.fetchurl {
          sha256 = "sha256-OBGFXOSN+Oq9uj/5O6tF0Kp7rxTY1AzNbhLK8G+EqVk=";
          url = "https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-linux-x64-${version}.tar.gz";
        };
      });
    })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # # List services that you want to enable:
  # systemd.services = {
  #   # Start resilio sync on boot
  #   resilio-sync = {
  #     description = "Resilio Sync service";
      
  #     serviceConfig = {
  #       Type = "forking";
  #       Restart = "on-failure";
  #       ExecStart = "${pkgs.resilio-sync}/bin/rslsync";
  #     };

  #     after = [ "network.target" "network-online.target" ];
  #     wantedBy = [ "multi-user.target" ];
  #   };
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
