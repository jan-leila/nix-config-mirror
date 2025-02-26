{
  config,
  lib,
  inputs,
  ...
}: {
  options.host.searx = {
    enable = lib.mkEnableOption "should searx be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that searx will be hosted at";
      default = "searx";
    };
  };

  config = lib.mkIf config.host.searx.enable {
    sops.secrets = {
      "services/searx" = {
        sopsFile = "${inputs.secrets}/defiant-services.yaml";
      };
    };
    host = {
      reverse_proxy.subdomains.${config.host.searx.subdomain} = {
        target = "http://localhost:${toString config.services.searx.settings.server.port}";
      };
    };
    services = {
      searx = {
        enable = true;
        environmentFile = config.sops.secrets."services/searx".path;

        # Rate limiting
        limiterSettings = {
          real_ip = {
            x_for = 1;
            ipv4_prefix = 32;
            ipv6_prefix = 56;
          };

          botdetection = {
            ip_limit = {
              filter_link_local = true;
              link_token = true;
            };
          };
        };

        settings = {
          server = {
            port = 8083;
            secret_key = "@SEARXNG_SECRET@";
          };

          # Search engine settings
          search = {
            safe_search = 2;
            autocomplete_min = 2;
            autocomplete = "duckduckgo";
          };

          # Enabled plugins
          enabled_plugins = [
            "Basic Calculator"
            "Hash plugin"
            "Tor check plugin"
            "Open Access DOI rewrite"
            "Hostnames plugin"
            "Unit converter plugin"
            "Tracker URL remover"
          ];
        };
      };
    };
  };
}
