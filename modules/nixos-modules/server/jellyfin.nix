{
  lib,
  pkgs,
  config,
  ...
}: let
  jellyfinPort = 8096;
  jellyfin_data_directory = "/var/lib/jellyfin";
  jellyfin_cache_directory = "/var/cache/jellyfin";
  jellyfin_media_directory = "/srv/jellyfin/media";
in {
  options.host.jellyfin = {
    enable = lib.mkEnableOption "should jellyfin be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that jellyfin will be hosted at";
      default = "jellyfin";
    };
    extraSubdomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "ex subdomain of base domain that jellyfin will be hosted at";
      default = [];
    };
  };

  config = lib.mkIf config.host.jellyfin.enable (
    lib.mkMerge [
      {
        services.jellyfin.enable = true;
        host.reverse_proxy.subdomains = lib.mkMerge ([
            {
              ${config.host.jellyfin.subdomain} = {
                target = "http://localhost:${toString jellyfinPort}";
              };
            }
          ]
          ++ (builtins.map (subdomain: {
              ${subdomain} = {
                target = "http://localhost:${toString jellyfinPort}";
              };
            })
            config.host.jellyfin.extraSubdomains));
        environment.systemPackages = [
          pkgs.jellyfin
          pkgs.jellyfin-web
          pkgs.jellyfin-ffmpeg
        ];
      }
      (lib.mkIf config.host.impermanence.enable {
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

        environment.persistence = {
          "/persist/system/root" = {
            enable = true;
            hideMounts = true;
            directories = [
              {
                directory = jellyfin_data_directory;
                user = "jellyfin";
                group = "jellyfin";
              }
              {
                directory = jellyfin_cache_directory;
                user = "jellyfin";
                group = "jellyfin";
              }
            ];
          };

          "/persist/system/jellyfin" = {
            enable = true;
            hideMounts = true;
            directories = [
              {
                directory = jellyfin_media_directory;
                user = "jellyfin";
                group = "jellyfin_media";
                mode = "1770";
              }
            ];
          };
        };
      })
    ]
  );
}
