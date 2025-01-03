{
  lib,
  config,
  ...
}: {
  imports = [];

  options = {
    apps = {
      base_domain = lib.mkOption {
        type = lib.types.str;
      };
      headscale = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that headscale will be hosted at";
          default = "headscale";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that headscale will be hosted at";
          default = "${config.apps.headscale.subdomain}.${config.apps.base_domain}";
        };
      };
      nextcloud = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that nextcloud will be hosted at";
          default = "nextcloud";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that nextcloud will be hosted at";
          default = "${config.apps.nextcloud.subdomain}.${config.apps.base_domain}";
        };
      };
    };
  };

  config = {
    systemd = {
      services = {
        headscale = {
          after = ["postgresql.service"];
          requires = ["postgresql.service"];
        };
      };
    };

    services = {
      # DNS stub needs to be disabled so pi hole can bind
      # resolved.extraConfig = "DNSStubListener=no";
      headscale = {
        enable = true;
        user = "headscale";
        group = "headscale";
        address = "0.0.0.0";
        port = 8080;
        settings = {
          server_url = "https://${config.apps.headscale.hostname}";
          dns.base_domain = "clients.${config.apps.headscale.hostname}";
          logtail.enabled = true;
          database = {
            type = "postgres";
            postgres = {
              host = "/run/postgresql";
              port = config.services.postgresql.settings.port;
              user = "headscale";
              name = "headscale";
            };
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts = {
          ${config.apps.headscale.hostname} = {
            # forceSSL = true;
            # enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };

    environment.systemPackages = [
      config.services.headscale.package
    ];
  };
}
