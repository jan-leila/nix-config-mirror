{
  lib,
  config,
  ...
}: let
  configDir = "/var/lib/hass";
in {
  options.host.home-assistant = {
    enable = lib.mkEnableOption "should home-assistant be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that home-assistant will be hosted at";
      default = "home-assistant";
    };
  };

  config = lib.mkIf config.host.home-assistant.enable (lib.mkMerge [
    {
      services.home-assistant = {
        enable = true;
        config.http = {
          server_port = 8082;
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1"];
          ip_ban_enabled = true;
          login_attempts_threshold = 10;
        };
      };
      host = {
        reverse_proxy.subdomains.${config.host.home-assistant.subdomain} = {
          target = "http://localhost:${toString config.services.home-assistant.config.http.server_port}";
        };
      };
    }
    (lib.mkIf config.host.impermanence.enable {
      assertions = [
        {
          assertion = config.services.home-assistant.configDir == configDir;
          message = "home assistant config directory does not match persistence";
        }
      ];
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          configDir
        ];
      };
    })
  ]);
}
