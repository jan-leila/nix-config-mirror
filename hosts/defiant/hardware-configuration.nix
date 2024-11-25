# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  security.sudo.extraConfig = "Defaults lecture=never";

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "aacraid" "ahci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
      # TODO: figure out some kind of snapshotting before rolebacks
      # postDeviceCommands = lib.mkAfter ''
      #   zfs rollback -r rpool/root@blank
      #   zfs rollback -r rpool/home@blank
      # '';
      # systemd = {
      #   enable = lib.mkDefault true;
      #   services.rollback = {
      #     description = "Rollback root filesystem to a pristine state on boot";
      #     wantedBy = [
      #       "zfs.target"
      #       "initrd.target"
      #     ];
      #     after = [
      #       "zfs-import-rpool.service"
      #     ];
      #     before = [
      #       "sysroot.mount"
      #       "fs.target"
      #     ];
      #     path = with pkgs; [
      #       zfs
      #     ];
      #     unitConfig.DefaultDependencies = "no";
      #     # serviceConfig = {
      #     #   Type = "oneshot";
      #     #   ExecStart =
      #     #     "${config.boot.zfs.package}/sbin/zfs rollback -r rpool/home@blank";
      #     # };
      #     serviceConfig.Type = "oneshot";
      #     script = ''
      #       zfs list -t snapshot || echo
      #       zfs rollback -r rpool/root@blank
      #       zfs rollback -r rpool/home@blank
      #     '';
      #   };
      # };
    };
    kernelModules = ["kvm-amd"];
    kernelParams = ["quiet"];
    extraModulePackages = [];

    supportedFilesystems = ["zfs"];

    zfs.extraPools = ["rpool"];
  };

  swapDevices = [];

  # fileSystems = {
  #   "/" = {
  #     neededForBoot = true;
  #   };

  #   "/home" = {
  #     neededForBoot = true;
  #   };

  #   "/persistent" = {
  #     neededForBoot = true;
  #   };
  # };

  networking = {
    hostId = "c51763d6";
    hostName = "defiant"; # Define your hostname.
    useNetworkd = true;
  };

  # environment.persistence."/persistent" = {
  #   enable = true;
  #   hideMounts = true;
  #   directories = [
  #     # "/run/secrets"

  #     "/etc/ssh"

  #     "/var/log"
  #     "/var/lib/nixos"
  #     "/var/lib/systemd/coredump"

  #     # config.apps.pihole.directory.root

  #     # config.apps.jellyfin.mediaDirectory
  #     # config.services.jellyfin.configDir
  #     # config.services.jellyfin.cacheDir
  #     # config.services.jellyfin.dataDir

  #     # "/var/hass" # config.users.users.hass.home
  #     # "/var/postgresql" # config.users.users.postgresql.home
  #     # "/var/forgejo" # config.users.users.forgejo.home
  #     # "/var/nextcloud" # config.users.users.nextcloud.home
  #     # "/var/headscale" # config.users.users.headscale.home
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #     # config.environment.sessionVariables.SOPS_AGE_KEY_FILE
  #   ];
  #   users.leyla = {
  #     directories = [
  #       "documents"
  #       ".ssh"
  #     ];
  #     files = [];
  #   };
  # };

  # systemd.services = {
  #   # https://github.com/openzfs/zfs/issues/10891
  #   systemd-udev-settle.enable = false;
  #   # Snapshots are not accessable on boot for some reason this should fix it
  #   # https://github.com/NixOS/nixpkgs/issues/257505
  #   zfs-mount = {
  #     serviceConfig = {
  #       # ExecStart = [ "${lib.getExe' pkgs.util-linux "mount"} -a -t zfs -o remount" ];
  #       ExecStart = [
  #         "${lib.getExe' pkgs.util-linux "mount"} -t zfs rpool/root -o remount"
  #         "${lib.getExe' pkgs.util-linux "mount"} -t zfs rpool/home -o remount"
  #         "${lib.getExe' pkgs.util-linux "mount"} -t zfs rpool/persistent -o remount"
  #       ];
  #     };
  #   };
  # };

  systemd.network = {
    enable = true;

    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
        };
      };
    };

    networks = {
      "30-enp4s0" = {
        matchConfig.Name = "enp4s0";
        networkConfig.Bond = "bond0";
        DHCP = "no";
      };
      "30-enp5s0" = {
        matchConfig.Name = "enp5s0";
        networkConfig.Bond = "bond0";
        DHCP = "no";
      };

      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig.RequiredForOnline = "carrier";
        networkConfig.LinkLocalAddressing = "no";
        DHCP = "ipv4";

        address = [
          # configure addresses including subnet mask
          "192.168.1.10/24"
          # TODO: ipv6 address configuration
        ];
      };
    };
  };

  networking.networkmanager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    # TODO: hardware graphics
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
