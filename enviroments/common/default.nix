{ pkgs, ... }:
{
  imports = [
      ../../users
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "leyla" ];

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

  users.groups.users = {};

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [ "leyla" ]; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
      };
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    gnupg.sshKeyPaths = [];

    age ={
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