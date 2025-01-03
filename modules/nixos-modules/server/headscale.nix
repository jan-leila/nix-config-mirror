{
  lib,
  config,
  ...
}: let
  hostname = "${config.host.headscale.subdomain}.${config.host.reverse_proxy.hostname}";
in {
  options.host.headscale = {
    enable = lib.mkEnableOption "should headscale be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that headscale will be hosted at";
      default = "headscale";
    };
  };

  config = lib.mkIf config.host.headscale.enable {
    host.reverse_proxy.subdomains.${config.host.jellyfin.subdomain} = {
      target = "http://localhost:${toString config.services.headscale.port}";
    };

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
          server_url = "https://${hostname}";
          dns.base_domain = "clients.${hostname}";
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
    };

    environment.systemPackages = [
      config.services.headscale.package
    ];
  };
}
