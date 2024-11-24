{pkgs, ...}: {
  imports = [];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["leyla"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

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

  services = {
    automatic-timezoned = {
      enable = true;
    };

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

  environment = {
    # List packages installed in system profile.
    systemPackages = with pkgs; [
      wget

      # version control
      git

      # system debuging tools
      iputils
      dnsutils
    ];

    sessionVariables = rec {
      SOPS_AGE_KEY_DIRECTORY = import ../../const/sops_age_key_directory.nix;
      SOPS_AGE_KEY_FILE = "${SOPS_AGE_KEY_DIRECTORY}/key.txt";
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
}
