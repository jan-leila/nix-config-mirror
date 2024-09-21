{lib, ...}: let
  bootDisk = devicePath: {
    type = "disk";
    device = devicePath;
    content = {
      type = "gpt";

      partitions = {
        boot = {
          size = "1M";
          type = "EF02"; # for grub MBR
        };
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
      };
    };
  };
  zfsDisk = devicePath: {
    type = "disk";
    device = devicePath;
    content = {
      type = "gpt";
      partitions = {
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
  cacheDisk = devicePath: swapSize: {
    type = "disk";
    device = devicePath;
    content = {
      type = "gpt";
      partitions = {
        encryptedSwap = {
          size = swapSize;
          content = {
            type = "swap";
            randomEncryption = true;
            discardPolicy = "both";
            resumeDevice = true;
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      boot = bootDisk "/dev/disk/by-path/pci-0000:23:00.3-usb-0:1:1.0-scsi-0:0:0:0";

      hd_13_tb_a = zfsDisk "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTCXVEB";
      hd_13_tb_b = zfsDisk "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTCXWSC";
      hd_13_tb_c = zfsDisk "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTD10EH";

      # ssd_2_tb_a = cacheDisk "64G" "/dev/disk/by-id/XXX";
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                # should this only mirror for this inital config with 3 drives we will used raidz2 for future configs???
                mode = "mirror";
                members = [
                  "hd_13_tb_a"
                  "hd_13_tb_b"
                  "hd_13_tb_c"
                ];
              }
            ];
            cache = [];
            # cache = [ "ssd_2_tb_a" ];
          };
        };

        options = {
          ashift = "12";
        };

        rootFsOptions = {
          encryption = "on";
          keyformat = "hex";
          keylocation = "prompt";
          compression = "lz4";
          xattr = "sa";
          acltype = "posixacl";
          "com.sun:auto-snapshot" = "false";
        };

        mountpoint = "/";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/mnt/home";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "var" = {
            type = "zfs_fs";
            mountpoint = "/var";
          };
        };
      };
    };
  };
}
