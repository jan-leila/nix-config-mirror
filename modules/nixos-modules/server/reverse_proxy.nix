{
  lib,
  config,
  ...
}: let
  dataDir = "/var/lib/acme";
  httpPort = 80;
  httpsPort = 443;
in {
  options.host.reverse_proxy = {
    enable = lib.mkEnableOption "turn on the reverse proxy";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "what host name are we going to be proxying from";
    };
    forceSSL = lib.mkOption {
      type = lib.types.bool;
      description = "force connections to use https";
      default = config.host.reverse_proxy.enableACME;
    };
    enableACME = lib.mkOption {
      type = lib.types.bool;
      description = "auto renew certificates";
      default = true;
    };
    subdomains = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          target = lib.mkOption {
            type = lib.types.str;
            description = "where should this host point to";
          };
          websockets = lib.mkEnableOption "should websockets be proxied";
        };
      }));
      default = {};
    };
  };

  config = lib.mkIf config.host.reverse_proxy.enable (lib.mkMerge [
    {
      security.acme = lib.mkIf config.host.reverse_proxy.enableACME {
        acceptTerms = true;
        defaults.email = "jan-leila@protonmail.com";
      };

      services.nginx = {
        enable = true;
        virtualHosts = lib.attrsets.mapAttrs' (name: value:
          lib.attrsets.nameValuePair "${name}.${config.host.reverse_proxy.hostname}" {
            forceSSL = config.host.reverse_proxy.forceSSL;
            enableACME = config.host.reverse_proxy.enableACME;
            locations."/" = {
              proxyPass = value.target;
              proxyWebsockets = value.websockets;
            };
          })
        config.host.reverse_proxy.subdomains;
      };

      networking.firewall.allowedTCPPorts = [
        httpPort
        httpsPort
      ];
    }
    (lib.mkIf config.host.impermanence.enable {
      # TODO: figure out how to write an assertion for this
      # assertions = [
      #   {
      #     assertion = security.acme.certs.<name>.directory == dataDir;
      #     message = "postgres data directory does not match persistence";
      #   }
      # ];
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          {
            directory = dataDir;
            user = "acme";
            group = "acme";
          }
        ];
      };
    })
  ]);
}
