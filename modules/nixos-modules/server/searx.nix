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
        settings = {
          server = {
            port = 8083;
            secret_key = "@SEARXNG_SECRET@";
          };
        };
      };
    };
  };
}
