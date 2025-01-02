{
  lib,
  config,
  ...
}: let
  forgejoPort = 8081;
  stateDir = "/var/lib/forgejo";
in {
  options.host.forgejo = {
    enable = lib.mkEnableOption "should forgejo be enabled on this computer";
    subdomain = lib.mkOption {
      type = lib.types.str;
      description = "subdomain of base domain that forgejo will be hosted at";
      default = "forgejo";
    };
  };

  config = lib.mkIf config.host.forgejo.enable (lib.mkMerge [
    {
      host = {
        reverse_proxy.subdomains.${config.host.forgejo.subdomain} = {
          target = "http://localhost:${toString forgejoPort}";
        };
        postgres = {
          enable = true;
          extraUsers = {
            forgejo = {
              isClient = true;
            };
          };
        };
      };

      services.forgejo = {
        enable = true;
        database = {
          type = "postgres";
          socket = "/run/postgresql";
        };
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "${config.host.forgejo.subdomain}.${config.host.reverse_proxy.hostname}";
            HTTP_PORT = forgejoPort;
          };
        };
      };
    }
    (lib.mkIf config.host.impermanence.enable {
      assertions = [
        {
          assertion = config.services.forgejo.stateDir == stateDir;
          message = "forgejo state directory does not match persistence";
        }
      ];
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          stateDir
        ];
      };
    })
  ]);
}
