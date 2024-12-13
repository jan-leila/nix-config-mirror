{
  lib,
  config,
  ...
}: {
  options.host.reverse_proxy = {
    enable = lib.mkEnableOption "turn on the reverse proxy";
    hostname = lib.mkOption {
      type = lib.type.string;
      description = "what host name are we going to be proxying from";
    };
    forceSSL = lib.mkOption {
      type = lib.type.boolean;
      description = "force connections to use https";
      default = true;
    };
    enableACME = lib.mkOption {
      type = lib.type.boolean;
      description = "auto renew certificates";
      default = true;
    };
    subdomains = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          target = lib.mkOption {
            type = lib.types.string;
            description = "where should this host point to";
          };
          websockets = lib.mkEnableOption "should websockets be proxied";
        };
      }));
    };
  };

  # TODO: impermanence for ACME keys
  config = {
    services.nginx = {
      enable = config.host.reverse_proxy.enable;
      virtualHosts = lib.attrsets.mapAttrs' (name: value:
        lib.attrsets.nameValuePair "${name}.${config.home.reverse_proxy.hostname}" {
          forceSSL = config.home.reverse_proxy.forceSSL;
          enableACME = config.home.reverse_proxy.enableACME;
          locations."/" = {
            proxyPass = value.target;
            proxyWebsockets = value.websockets;
          };
        })
      config.host.reverse_proxy.subdomains;
    };
  };
}
