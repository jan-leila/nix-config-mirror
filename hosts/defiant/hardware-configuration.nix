# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../hardware-common.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "aacraid" "ahci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    supportedFilesystems = ["zfs"];

    zfs.extraPools = ["zroot"];
  };

  swapDevices = [];

  networking = {
    hostId = "c51763d6";
    hostName = "defiant"; # Define your hostname.
    useNetworkd = true;
  };

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
      };
      "30-enp5s0" = {
        matchConfig.Name = "enp5s0";
        networkConfig.Bond = "bond0";
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    # TODO: hardware graphics
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
