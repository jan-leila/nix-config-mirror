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

  users.leyla.isThinUser = true;

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "leyla" ];

  nixpkgs.config.allowUnfree = true;

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
      services.xserver.displayManager = {
        gdm.enable = true;
      };
      services.xserver.desktopManager = {
        gnome.enable = true;
        desktopManager.xterm.enable = false;
      };

      # Get rid of xTerm
      excludePackages = [ pkgs.xterm ];
    };

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

    nfs.server = {
      enable = true;
      exports = ''
        /srv/nfs4/docker 192.168.1.0/24(rw,sync,crossmnt,no_subtree_check)

        /srv/nfs4/leyla 192.168.1.0/22(rw,sync,no_subtree_check,nohide)
        /srv/nfs4/eve   192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
        /srv/nfs4/share 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
        
        # /export         192.168.1.10(rw,fsid=0,no_subtree_check) 192.168.1.15(rw,fsid=0,no_subtree_check)
        # /export/kotomi  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
        # /export/mafuyu  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
        # /export/sen     192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
        # /export/tomoyo  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };

  # disable computer sleeping
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  fileSystems = {
    "/srv/nfs4/docker" = {
      device = "/home/docker";
      options = [ "bind" ];
    };

    "/srv/nfs4/users" = {
      device = "/home/users";
      options = [ "bind" ];
    };

    "/srv/nfs4/leyla" = {
      device = "/home/leyla";
      options = [ "bind" ];
    };

    "/srv/nfs4/eve" = {
      device = "/home/eve";
      options = [ "bind" ];
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