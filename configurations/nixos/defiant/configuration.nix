# server nas
{pkgs, ...}: {
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
      };
    };
    fail2ban = {
      enable = true;
    };
    network_storage = {
      enable = true;
      directories = [
        {
          folder = "leyla";
          user = "leyla";
          group = "leyla";
        }
        {
          folder = "eve";
          user = "eve";
          group = "eve";
        }
        {
          folder = "users";
          user = "root";
          group = "users";
        }
      ];
      nfs = {
        enable = true;
        directories = ["leyla" "eve"];
      };
    };
    reverse_proxy = {
      enable = true;
      enableACME = false;
      hostname = "jan-leila.com";
    };
    postgres = {
      extraUsers = {
        leyla = {
          isAdmin = true;
        };
      };
    };
    podman = {
      macvlan = {
        subnet = "192.168.1.0/24";
        gateway = "192.168.1.1";
        networkInterface = "bond0";
      };
    };
    jellyfin = {
      enable = true;
      subdomain = "media";
    };
    forgejo = {
      enable = true;
      subdomain = "git";
    };
    searx = {
      enable = true;
      subdomain = "search";
    };
    home-assistant = {
      enable = true;
      subdomain = "home";
    };
    pihole = {
      enable = true;
      ip = "192.168.1.201";
    };
    nextcloud = {
      enable = true;
      subdomain = "drive";
    };
  };
  networking = {
    hostId = "c51763d6";
  };

  services = {
    # TODO: move zfs scrubbing into module
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

    ollama = {
      enable = true;

      loadModels = [
        "deepseek-coder:6.7b"
        "deepseek-r1:8b"
        "deepseek-r1:32b"
        "deepseek-r1:70b"
      ];
    };
  };

  # disable computer sleeping
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  services.xserver.displayManager.gdm.autoSuspend = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
