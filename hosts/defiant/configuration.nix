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

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age ={
      keyFile = "/home/leyla/.config/sops/age/keys.txt";
      # sshKeyPaths = ["${config.home.homeDirectory}/.ssh/nix-ed25519"];
      # generateKey = true;
    };
  };

  # home.sessionVariables = {
  #   SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops-nix/key.txt";
  # };

  users.leyla.isThinUser = true;

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    # devices = [ "/dev/disk/by-path/pci-0000:23:00.3-usb-0:1:1.0-scsi-0:0:0:0-part2" ];
    # mirroredBoots = [
    #   { devices = [ "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTCXVEB-part1" ]; path = "/boot1"; efiSysMountPoint = "/boot"; }
    #   { devices = [ "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTCXWSC-part1" ]; path = "/boot2"; efiSysMountPoint = "/boot2"; }
    #   { devices = [ "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTD10EH-part1" ]; path = "/boot3"; efiSysMountPoint = "/boot3"; }
    # ];
  };

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostId = "c8985fc5"; # TODO: populate this when I get home
  networking.hostName = "defiant"; # Define your hostname.

  nixpkgs.config.allowUnfree = true;

  # temp enable desktop enviroment for setup
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.xterm.enable = false;

  # disable computer sleeping
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # temp enable password auth over ssh for setup
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "leyla" ]; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}