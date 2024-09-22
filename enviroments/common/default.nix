{pkgs, ...}: {
  imports = [
    ../../users
  ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["leyla"];
    };
    gc.automatic = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users = {
    users = {
      leyla = {
        uid = 1000;
        description = "Leyla";
        group = "leyla";
      };

      ester = {
        uid = 1001;
        description = "Ester";
        group = "ester";
      };

      eve = {
        uid = 1002;
        description = "Eve";
        group = "eve";
      };

      jellyfin = {
        uid = 2000;
        group = "jellyfin";
        isSystemUser = true;
      };

      forgejo = {
        uid = 2002;
        group = "forgejo";
        isSystemUser = true;
      };

      # pihole = {
      #   uid = 2003;
      #   group = "forgejo";
      #   isSystemUser = true;
      # };
    };

    groups = {
      leyla = {
        gid = 1000;
        members = ["lelya"];
      };

      ester = {
        gid = 1001;
        members = ["ester"];
      };

      eve = {
        gid = 1002;
        members = ["eve"];
      };

      jellyfin = {
        gid = 2000;
        members = ["jellyfin" "leyla"];
      };

      jellyfin_media = {
        gid = 2001;
        members = ["jellyfin" "leyla" "ester" "eve"];
      };

      forgejo = {
        gid = 2002;
        members = ["forgejo" "leyla"];
      };

      # pihole = {
      #   gid = 2003;
      #   members = ["pihole" "leyla"];
      # };
    };
  };

  services = {
    openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = ["leyla"]; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
      };
    };
  };

  sops = {
    defaultSopsFormat = "yaml";
    gnupg.sshKeyPaths = [];

    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = [];
      # generateKey = true;
    };
  };
  environment.sessionVariables = {
    AGE_KEY_FILE_LOCATION = "/var/lib/sops-nix/";
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget

    # version control
    git

    # system debuging tools
    iputils
    dnsutils
  ];
}
