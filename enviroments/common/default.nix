{ pkgs, ... }:
{
  imports = [
      ../../users
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age ={
      keyFile = "/var/lib/sops-nix/key.txt";
      # sshKeyPaths = ["${config.home.homeDirectory}/.ssh/nix-ed25519"];
      # generateKey = true;
    };
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