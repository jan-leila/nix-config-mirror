{lib, ...}: let
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
            pool = "rpool";
          };
        };
      };
    };
  };
  cacheDisk = devicePath: {
    type = "disk";
    device = devicePath;
    content = {
      type = "gpt";
      partitions = {
        # We are having to boot off of the nvm cache drive because I cant figure out how to boot via the HBA
        ESP = {
          size = "64M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "rpool";
          };
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      hd_18_tb_a = zfsDisk "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTCXVEB";
      hd_18_tb_b = zfsDisk "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTCXWSC";
      hd_18_tb_c = zfsDisk "/dev/disk/by-id/ata-ST18000NE000-3G6101_ZVTD10EH";
      hd_18_tb_d = zfsDisk "/dev/disk/by-id/ata-ST18000NT001-3NF101_ZVTE0S3Q";
      hd_18_tb_e = zfsDisk "/dev/disk/by-id/ata-ST18000NT001-3NF101_ZVTEF27J";
      hd_18_tb_f = zfsDisk "/dev/disk/by-id/ata-ST18000NT001-3NF101_ZVTEZACV";

      ssd_4_tb_a = cacheDisk "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7KGNU0X907881F";
    };
    zpool = {
      rpool = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz2";
                members = [
                  "hd_18_tb_a"
                  "hd_18_tb_b"
                  "hd_18_tb_c"
                  "hd_18_tb_d"
                  "hd_18_tb_e"
                  "hd_18_tb_f"
                ];
              }
            ];
            cache = ["ssd_4_tb_a"];
          };
        };

        options = {
          ashift = "12";
          autotrim = "on";
        };

        rootFsOptions =
          {
            canmount = "off";
            mountpoint = "none";

            xattr = "sa";
            acltype = "posixacl";
            relatime = "on";

            compression = "lz4";

            "com.sun:auto-snapshot" = "false";
          }
          # TODO: have an option to enable encryption
          // lib.attrsets.optionalAttrs false {
            encryption = "on";
            keyformat = "hex";
            keylocation = "prompt";
          };

        datasets = {
          # local datasets are for data that should be considered ephemeral
          "local" = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          # the nix directory is local because its all generable from our configuration
          "local/system/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              relatime = "off";
              canmount = "on";
            };
          };
          "local/system/sops" = {
            type = "zfs_fs";
            mountpoint = import ../../../const/sops_age_key_directory.nix;
            options = {
              atime = "off";
              relatime = "off";
              canmount = "on";
            };
          };
          "local/system/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              canmount = "on";
            };
            postCreateHook = ''
              zfs snapshot rpool/local/system/root@blank
            '';
          };
          "local/home/leyla" = {
            type = "zfs_fs";
            mountpoint = "/home/leyla";
            options = {
              canmount = "on";
            };
            postCreateHook = ''
              zfs snapshot rpool/local/home/leyla@blank
            '';
          };

          # persist datasets are datasets that contain information that we would like to keep around
          "persist" = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          "persist/system/root" = {
            type = "zfs_fs";
            mountpoint = "/persist/system/root";
            options = {
              "com.sun:auto-snapshot" = "true";
              mountpoint = "/persist/system/root";
            };
          };
          "persist/home/leyla" = {
            type = "zfs_fs";
            mountpoint = "/persist/home/leyla";
            options = {
              "com.sun:auto-snapshot" = "true";
              mountpoint = "/persist/home/leyla";
            };
          };

          # TODO: separate dataset for logs that wont participate in snapshots and rollbacks with the rest of the system
        };
      };
    };
  };
  networking = {
    hostId = "c51763d6";
  };
}
