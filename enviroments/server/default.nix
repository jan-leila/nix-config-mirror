{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common
  ];

  options = {
    domains = {
      base_domain = lib.mkOption {
        type = lib.types.str;
      };
      headscale = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that headscale will be hosted at";
          default = "headscale";
        };
      };
      jellyfin = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that jellyfin will be hosted at";
          default = "jellyfin";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hosname that jellyfin will be hosted at";
          default = "${config.domains.jellyfin.subdomain}.${config.domains.base_domain}";
        };
      };
      forgejo = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that foregjo will be hosted at";
          default = "forgejo";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hosname that forgejo will be hosted at";
          default = "${config.domains.forgejo.subdomain}.${config.domains.base_domain}";
        };
      };
    };
  };

  config = {
    # virtualisation.oci-containers.containers.pihole = {
    #   image = "pihole/pihole:latest";
    #   environment = {
    #     TZ = "America/Chicago"; # TODO: set this to the systems timezone
    #     WEBPASSWORD_FILE = "..."; # TODO: set this from secrets file/config that is set to secrets file (I think this also needs to be mounted in volumns?)
    #   };
    #   volumes = [
    #     "/home/docker/pihole:/etc/pihole:rw" # TODO; set this based on configs
    #   ];
    #   ports = [
    #     "53:53/tcp"
    #     "53:53/udp"
    #     "3000:80/tcp" # TODO: bind container ip address?
    #   ];
    #   log-driver = "journald";
    #   extraOptions = [
    #     "--ip=172.18.1.5" # TODO: set this to some ip address from configs
    #     "--network-alias=pihole" # TODO: set this from configs
    #     "--network=nas_default"
    #   ];
    # };

    systemd = {
      tmpfiles.rules = [
        "d /home/jellyfin 755 jellyfin jellyfin -"
        "d /home/jellyfin/media 775 jellyfin jellyfin_media -"
        "d /home/jellyfin/config 750 jellyfin jellyfin -"
        "d /home/jellyfin/cache 755 jellyfin jellyfin_media -"
        "d /home/forgejo 750 forgejo forgejo -"
        "d /home/forgejo/data 750 forgejo forgejo -"
        # "d /home/forgejo 750 pihole pihole -"
      ];

      # services = {
      #   pihole = {
      #     serviceConfig = {
      #       Restart = lib.mkOverride 500 "always";
      #     };
      #     after = [
      #       "podman-network-nas_default.service"
      #     ];
      #     requires = [
      #       "podman-network-nas_default.service"
      #     ];
      #     partOf = [
      #       "podman-compose-nas-root.target"
      #     ];
      #     wantedBy = [
      #       "podman-compose-nas-root.target"
      #     ];
      #   };
      # };

      # disable computer sleeping
      targets = {
        sleep.enable = false;
        suspend.enable = false;
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };
    };

    services = {
      nfs.server = {
        enable = true;
        exports = ''
          /home/leyla 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
          /home/eve   192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
          /home/ester 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
          /home/users 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
        '';
      };

      postgresql = {
        enable = true;
        ensureDatabases = ["forgejo"];
        identMap = ''
          # ArbitraryMapName systemUser DBUser
          superuser_map      root      postgres
          superuser_map      postgres  postgres
          superuser_map      forgejo   forgejo
        '';
        # configuration here lets users access the db that matches their name and lets user postgres access everything
        authentication = pkgs.lib.mkOverride 10 ''
          # type database DBuser   auth-method  optional_ident_map
          local sameuser  all     peer        map=superuser_map
        '';
      };

      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8080;
        settings = {
          server_url = "http://${config.domains.headscale.subdomain}.${config.domains.base_domain}";
          dns_config.base_domain = config.domains.base_domain;
          logtail.enabled = false;
        };
      };

      jellyfin = {
        enable = true;
        user = "jellyfin";
        group = "jellyfin";
        dataDir = "/home/jellyfin/config"; # location on existing server: /home/docker/jellyfin/config
        cacheDir = "/home/jellyfin/cache"; # location on existing server: /home/docker/jellyfin/cache
      };

      forgejo = {
        enable = true;
        database.type = "postgres";
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = config.domains.forgejo.hostname;
            HTTP_PORT = 8081;
          };
          service.DISABLE_REGISTRATION = true;
        };
        stateDir = "/home/forgejo/data";
      };

      nginx = {
        enable = false; # TODO: enable this when you want to test all the configs
        virtualHosts = {
          ${config.domains.headscale.hostname} = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
          };
          ${config.domains.jellyfin.hostname} = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://localhost:8096";
          };
          ${config.domains.forgejo.hostname} = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "jan-leila@protonmail.com";
    };

    networking.firewall.allowedTCPPorts = [2049 8081];

    environment.systemPackages = [
      config.services.headscale.package
      pkgs.jellyfin
      pkgs.jellyfin-web
      pkgs.jellyfin-ffmpeg
    ];
  };
}
