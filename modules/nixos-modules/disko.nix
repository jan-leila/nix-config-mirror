{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  # there currently is a bug with disko that causes long disk names to be generated improperly this hash function should alleviate it when used for disk names instead of what we are defaulting to
  # max gpt length is 36 and disk adds formats it like disk-xxxx-zfs which means we need to be 9 characters under that
  hashDisk = drive: (builtins.substring 0 27 (builtins.hashString "sha256" drive));

  vdevs =
    builtins.map (
      disks:
        builtins.map (disk: lib.attrsets.nameValuePair (hashDisk disk) disk) disks
    )
    config.host.storage.pool.vdevs;
  cache =
    builtins.map (
      disk: lib.attrsets.nameValuePair (hashDisk disk) disk
    )
    config.host.storage.pool.cache;
in {
  options.host.storage = {
    enable = lib.mkEnableOption "are we going create zfs disks with disko on this device";
    encryption = lib.mkEnableOption "is the vdev going to be encrypted";
    notifications = {
      enable = lib.mkEnableOption "are notifications enabled";
      host = lib.mkOption {
        type = lib.types.str;
        description = "what is the host that we are going to send the email to";
      };
      port = lib.mkOption {
        type = lib.types.port;
        description = "what port is the host using to receive mail on";
      };
      to = lib.mkOption {
        type = lib.types.str;
        description = "what account is the email going to be sent to";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "what user is the email going to be set from";
      };
      tokenFile = lib.mkOption {
        type = lib.types.str;
        description = "file containing the password to be used by msmtp for notifications";
      };
    };
    pool = {
      vdevs = lib.mkOption {
        type = lib.types.listOf (lib.types.listOf lib.types.str);
        description = "list of disks that are going to be in";
        default = [config.host.storage.pool.drives];
      };
      drives = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "list of drives that are going to be in the vdev";
        default = [];
      };
      cache = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "list of drives that are going to be used as cache";
        default = [];
      };
      extraDatasets = lib.mkOption {
        type = lib.types.attrsOf (inputs.disko.lib.subType {
          types = {inherit (inputs.disko.lib.types) zfs_fs zfs_volume;};
        });
        description = "List of datasets to define";
        default = {};
      };
    };
  };

  config = lib.mkIf config.host.storage.enable {
    programs.msmtp = lib.mkIf config.host.storage.notifications.enable {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = config.host.storage.notifications.port;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
        tls = "on";
        auth = "login";
        tls_starttls = "off";
      };
      accounts = {
        zfs_notifications = {
          host = config.host.storage.notifications.host;
          passwordeval = "cat ${config.host.storage.notifications.tokenFile}";
          user = config.host.storage.notifications.user;
          from = config.host.storage.notifications.user;
        };
      };
    };

    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;

      zed = lib.mkIf config.host.storage.notifications.enable {
        # this option is broken we are just going to disable it
        enableMail = false;

        settings = {
          ZED_DEBUG_LOG = "/tmp/zed.debug.log";
          ZED_EMAIL_ADDR = [config.host.storage.notifications.to];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_EMAIL_OPTS = "@ADDRESS@";

          ZED_NOTIFY_INTERVAL_SECS = 3600;
          ZED_NOTIFY_VERBOSE = true;

          ZED_USE_ENCLOSURE_LEDS = true;
          ZED_SCRUB_AFTER_RESILVER = true;
        };
      };
    };

    disko.devices = {
      disk = (
        builtins.listToAttrs (
          (
            builtins.map
            (drive:
              lib.attrsets.nameValuePair (drive.name) {
                type = "disk";
                device = "/dev/disk/by-id/${drive.value}";
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
              })
            (lib.lists.flatten vdevs)
          )
          ++ (
            builtins.map
            (drive:
              lib.attrsets.nameValuePair (drive.name) {
                type = "disk";
                device = "/dev/disk/by-id/${drive.value}";
                content = {
                  type = "gpt";
                  partitions = {
                    # We are having to boot off of the nvm cache drive because I cant figure out how to boot via the HBA
                    ESP = {
                      # 2G here because its not much relative to how much storage we have for caching
                      size = "2G";
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
              })
            cache
          )
        )
      );
      zpool = {
        rpool = {
          type = "zpool";
          mode = {
            topology = {
              type = "topology";
              vdev = (
                builtins.map (disks: {
                  mode = "raidz2";
                  members =
                    builtins.map (disk: disk.name) disks;
                })
                vdevs
              );
              cache = builtins.map (disk: disk.name) cache;
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
            // (
              lib.attrsets.optionalAttrs config.host.storage.encryption {
                encryption = "on";
                keyformat = "hex";
                keylocation = "prompt";
              }
            );

          datasets = lib.mkMerge [
            (lib.attrsets.mapAttrs (name: value: {
                type = value.type;
                options = value.options;
                mountpoint = value.mountpoint;
                postCreateHook = value.postCreateHook;
              })
              config.host.storage.pool.extraDatasets)
          ];
        };
      };
    };
  };
}
