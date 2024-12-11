{
  config,
  lib,
  ...
}: {
  options.host.impermanence.enable = lib.mkEnableOption "are we going to use impermanence on this device";

  # TODO: validate that config.host.storage.enable is enabled
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
        boot.initrd.postResumeCommands = lib.mkAfter ''
                    zfs rollback -r rpool/local/system/root@blank
          1        '';

        fileSystems = {
          "/".neededForBoot = true;
          "/persist/system/root".neededForBoot = true;
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
          };
          # this is where root data actually lives
          "persist/system/root" = {
            type = "zfs_fs";
            mountpoint = "/persist/system/root";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "persist/system/var/log" = {
            type = "zfs_fs";
            mountpoint = "/persist/system/var/log";
          };
        };

        environment.persistence."/persist/system/root" = {
          enable = true;
          hideMounts = true;
          directories = [
            "/etc/ssh"

            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"

            # config.apps.pihole.directory.root

            # config.apps.jellyfin.mediaDirectory
            # config.services.jellyfin.configDir
            # config.services.jellyfin.cacheDir
            # config.services.jellyfin.dataDir

            # "/var/hass" # config.users.users.hass.home
            # "/var/postgresql" # config.users.users.postgresql.home
            # "/var/forgejo" # config.users.users.forgejo.home
            # "/var/nextcloud" # config.users.users.nextcloud.home
            # "/var/headscale" # config.users.users.headscale.home
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
