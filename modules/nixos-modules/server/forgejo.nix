{
  lib,
  config,
  ...
}: let
  forgejoPort = 8081;
  stateDir = "/var/lib/forgejo";
  db_user = "forgejo";
  sshPort = 2222;
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
            ${db_user} = {
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
            START_SSH_SERVER = true;
            SSH_LISTEN_PORT = sshPort;
            SSH_PORT = 22;
            # TODO: we need to create this user, and then store their authorized keys somewhere and have both ssh server allow login in as that user based on those authorized keys
            BUILTIN_SSH_SERVER_USER = "git";
          };
          service = {
            DISABLE_REGISTRATION = true;
          };
          database = {
            DB_TYPE = "postgres";
            NAME = db_user;
            USER = db_user;
          };
        };
      };

      networking.firewall.allowedTCPPorts = [
        config.services.forgejo.settings.server.SSH_LISTEN_PORT
      ];
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
          {
            directory = stateDir;
            user = "forgejo";
            group = "forgejo";
          }
        ];
      };
    })
  ]);
}
