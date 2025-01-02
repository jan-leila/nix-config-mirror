{
  lib,
  pkgs,
  config,
  ...
}: let
  jellyfinPort = 8096;
  jellyfin_data_directory = "/var/lib/jellyfin";
  jellyfin_cache_directory = "/var/cache/jellyfin";
in {
  options.host.jellyfin = {
    enable = lib.mkEnableOption "should jellyfin be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that jellyfin will be hosted at";
      default = "jellyfin";
    };
  };

  config = lib.mkIf config.host.jellyfin.enable (
    lib.mkMerge [
      {
        services.jellyfin.enable = true;
        host.reverse_proxy.subdomains.${config.host.jellyfin.subdomain} = {
          target = "http://localhost:${toString jellyfinPort}";
        };
        environment.systemPackages = [
          pkgs.jellyfin
          pkgs.jellyfin-web
          pkgs.jellyfin-ffmpeg
        ];
      }
      (lib.mkIf config.host.impermanence.enable {
        assertions = [
          {
            assertion = config.services.jellyfin.dataDir == jellyfin_data_directory;
            message = "jellyfin data directory does not match persistence";
          }
          {
            assertion = config.services.jellyfin.cacheDir == jellyfin_cache_directory;
            message = "jellyfin cache directory does not match persistence";
          }
        ];

        environment.persistence."/persist/system/jellyfin" = {
          enable = true;
          hideMounts = true;
          directories = [
            jellyfin_data_directory
            jellyfin_cache_directory
          ];
        };

        fileSystems."/persist/system/jellyfin".neededForBoot = true;

        host.storage.pool.extraDatasets = {
          # sops age key needs to be available to pre persist for user generation
          "persist/system/jellyfin" = {
            type = "zfs_fs";
            mountpoint = "/persist/system/jellyfin";
            options = {
              atime = "off";
              relatime = "off";
              canmount = "on";
            };
          };
        };
      })
    ]
  );
}
