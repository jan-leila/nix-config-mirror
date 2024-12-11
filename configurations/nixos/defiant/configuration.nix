# server nas
{pkgs, ...}: {
  imports = [
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
    };
    impermanence.enable = true;
    storage = {
      enable = true;
      encryption = true;
      pool = {
        drives = [
          "ata-ST18000NE000-3G6101_ZVTCXVEB"
          "ata-ST18000NE000-3G6101_ZVTCXWSC"
          "ata-ST18000NE000-3G6101_ZVTD10EH"
          "ata-ST18000NT001-3NF101_ZVTE0S3Q"
          "ata-ST18000NT001-3NF101_ZVTEF27J"
          "ata-ST18000NT001-3NF101_ZVTEZACV"
        ];
        cache = [
          "nvme-Samsung_SSD_990_PRO_4TB_S7KGNU0X907881F"
        ];
        # extraDatasets = {
        #   "persist/system/var/lib/jellyfin/media" = {
        #     type = "zfs_fs";
        #     mountpoint = "/persist/system/var/lib/jellyfin/media";
        #   };
        # };
      };
    };
  };
  networking = {
    hostId = "c51763d6";
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
