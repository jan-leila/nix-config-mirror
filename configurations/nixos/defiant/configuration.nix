# server nas
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    # ./services.nix
  ];

  nixpkgs.config.allowUnfree = true;

  host = {
    users = {
      leyla = {
        isDesktopUser = true;
        isTerminalUser = true;
        isPrincipleUser = true;
      };
      ester.isNormalUser = false;
      eve.isNormalUser = false;
    };
  };

  # apps = {
  #   base_domain = "jan-leila.com";
  #   macvlan = {
  #     subnet = "192.168.1.0/24";
  #     gateway = "192.168.1.1";
  #     networkInterface = "bond0";
  #   };
  #   pihole = {
  #     image = "pihole/pihole:2024.07.0";
  #     ip = "192.168.1.201";
  #   };
  #   headscale = {
  #     subdomain = "vpn";
  #   };
  #   jellyfin = {
  #     subdomain = "media";
  #   };
  #   forgejo = {
  #     subdomain = "git";
  #   };
  #   nextcloud = {
  #     subdomain = "drive";
  #   };
  # };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };

    # temp enable desktop enviroment for setup
    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment.
      displayManager = {
        gdm.enable = true;
      };
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };

      # Get rid of xTerm
      excludePackages = [pkgs.xterm];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
