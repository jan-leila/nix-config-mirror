{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  dataDir = "/var/lib/nextcloud";
in {
  options.host.nextcloud = {
    enable = lib.mkEnableOption "should nextcloud be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that nextcloud will be hosted at";
      default = "nextcloud";
    };
  };

  config = lib.mkIf config.host.nextcloud.enable (lib.mkMerge [
    {
      sops.secrets = {
        "services/nextcloud_adminpass" = {
          sopsFile = "${inputs.secrets}/defiant-services.yaml";
          owner = config.users.users.nextcloud.name;
        };
      };

      host.reverse_proxy.subdomains.${config.host.jellyfin.subdomain} = {};

      services = {
        nextcloud = {
          enable = true;
          package = pkgs.nextcloud30;
          hostName = "${config.host.nextcloud.subdomain}.${config.host.reverse_proxy.hostname}";
          config = {
            adminpassFile = config.sops.secrets."services/nextcloud_adminpass".path;
          };
        };
      };
    }
    (lib.mkIf config.host.impermanence.enable {
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          {
            directory = dataDir;
            user = "nextcloud";
            group = "nextcloud";
          }
        ];
      };
    })
  ]);
}
