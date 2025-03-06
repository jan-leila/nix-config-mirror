{
  config,
  lib,
  ...
}: {
  options.host.impermanence.enable = lib.mkEnableOption "are we going to use impermanence on this device";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(config.host.impermanence.enable && !config.host.storage.enable);
          message = ''
            Disko storage must be enabled to use impermanence.
          '';
        }
      ];
    }
    (
      lib.mkIf config.host.impermanence.enable {
        assertions = [
          {
            assertion = config.host.impermanence.enable && config.host.storage.enable;
            message = "Impermanence can not be used without managed host storage.";
          }
        ];

        programs.fuse.userAllowOther = true;

        boot.initrd.postResumeCommands = lib.mkAfter ''
          zfs rollback -r rpool/local/system/root@blank
        '';

        fileSystems = {
          "/".neededForBoot = true;
          "/persist/system/root".neededForBoot = true;
          "/persist/system/var/log".neededForBoot = true;
        };

        host.storage.pool.extraDatasets = {
          # local datasets are for data that should be considered ephemeral
          "local" = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          # nix directory needs to be available pre persist and doesn't need to be snapshotted or backed up
          "local/system/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              relatime = "off";
              canmount = "on";
            };
          };
          # dataset for root that gets rolled back on every boot
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

          # persist datasets are datasets that contain information that we would like to keep around
          "persist" = {
            type = "zfs_fs";
            options.canmount = "off";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          # this is where root data actually lives
          "persist/system/root" = {
            type = "zfs_fs";
            mountpoint = "/persist/system/root";
          };
          "persist/system/var/log" = {
            type = "zfs_fs";
            mountpoint = "/persist/system/var/log";
            # logs should be append only so we shouldn't need to snapshot them
            options = {
              "com.sun:auto-snapshot" = "false";
            };
          };
        };

        environment.persistence."/persist/system/var/log" = {
          enable = true;
          hideMounts = true;
          directories = [
            "/var/log"
          ];
        };

        environment.persistence."/persist/system/root" = {
          enable = true;
          hideMounts = true;
          directories = [
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
          ];
          files = [
            "/etc/machine-id"
          ];
        };

        security.sudo.extraConfig = "Defaults lecture=never";
      }
    )
  ];
}
