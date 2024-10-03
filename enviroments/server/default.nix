{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common
  ];

  options = {
    apps = {
      base_domain = lib.mkOption {
        type = lib.types.str;
      };
      macvlan = {
        subnet = lib.mkOption {
          type = lib.types.str;
          description = "Subnet for macvlan address range";
        };
        gateway = lib.mkOption {
          type = lib.types.str;
          description = "Gateway for macvlan";
          # TODO: see if we can default this to systemd network gateway
        };
        networkInterface = lib.mkOption {
          type = lib.types.str;
          description = "Parent network interface for macvlan";
          # TODO: see if we can default this some interface?
        };
      };
      pihole = {
        image = lib.mkOption {
          type = lib.types.str;
          description = "container image to use for pi-hole";
        };
        # TODO: check against subnet for macvlan
        ip = lib.mkOption {
          type = lib.types.str;
          description = "ip address to use for pi-hole";
        };
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
          default = "${config.apps.jellyfin.subdomain}.${config.apps.base_domain}";
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
          default = "${config.apps.forgejo.subdomain}.${config.apps.base_domain}";
        };
      };
    };
  };

  config = {
    sops.secrets = {
      "services/pi-hole" = {
        sopsFile = "${inputs.secrets}/defiant-services.yaml";
      };
    };

    virtualisation = {
      # Runtime
      podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          # Required for container networking to be able to use names.
          dns_enabled = true;
        };
      };

      oci-containers = {
        backend = "podman";

        containers = {
          pihole = let
            passwordFileLocation = "/var/lib/pihole/webpassword.txt";
          in {
            image = config.apps.pihole.image;
            volumes = [
              "/home/pihole:/etc/pihole:rw" # TODO; set this based on configs and bond with tmpfiles.rules
              "${config.sops.secrets."services/pi-hole".path}:${passwordFileLocation}"
            ];
            environment = {
              TZ = "America/Chicago";
              WEBPASSWORD_FILE = passwordFileLocation;
              PIHOLE_UID = toString config.users.users.pihole.uid;
              PIHOLE_GID = toString config.users.groups.pihole.gid;
            };
            log-driver = "journald";
            extraOptions = [
              "--ip=${config.apps.pihole.ip}"
              "--network=macvlan"
            ];
          };
        };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d /home/jellyfin 755 jellyfin jellyfin -"
        "d /home/jellyfin/media 775 jellyfin jellyfin_media -"
        "d /home/jellyfin/config 750 jellyfin jellyfin -"
        "d /home/jellyfin/cache 755 jellyfin jellyfin_media -"
        "d /home/forgejo 750 forgejo forgejo -"
        "d /home/forgejo/data 750 forgejo forgejo -"
        "d /home/pihole 750 pihole pihole -"
      ];

      services = {
        "podman-pihole" = {
          serviceConfig = {
            Restart = lib.mkOverride 500 "always";
          };
          after = [
            "podman-network-macvlan.service"
          ];
          requires = [
            "podman-network-macvlan.service"
          ];
          partOf = [
            "podman-compose-root.target"
          ];
          wantedBy = [
            "podman-compose-root.target"
          ];
        };

        "podman-network-macvlan" = {
          path = [pkgs.podman];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "podman network rm -f macvlan";
          };
          script = ''
            podman network inspect macvlan || podman network create --driver macvlan --subnet ${config.apps.macvlan.subnet} --gateway ${config.apps.macvlan.gateway} --opt parent=${config.apps.macvlan.networkInterface} macvlan
          '';
          partOf = ["podman-compose-root.target"];
          wantedBy = ["podman-compose-root.target"];
        };
      };

      # disable computer sleeping
      targets = {
        sleep.enable = false;
        suspend.enable = false;
        hibernate.enable = false;
        hybrid-sleep.enable = false;

        # Root service
        # When started, this will automatically create all resources and start
        # the containers. When stopped, this will teardown all resources.
        "podman-compose-root" = {
          unitConfig = {
            Description = "Root target for podman targets.";
          };
          wantedBy = ["multi-user.target"];
        };
      };
    };

    services = {
      # DNS stub needs to be disabled so pi hole can bind
      # resolved.extraConfig = "DNSStubListener=no";

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
          server_url = "http://${config.apps.headscale.subdomain}.${config.apps.base_domain}";
          dns_config.base_domain = config.apps.base_domain;
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
            DOMAIN = config.apps.forgejo.hostname;
            HTTP_PORT = 8081;
          };
          service.DISABLE_REGISTRATION = true;
        };
        stateDir = "/home/forgejo/data";
      };

      nginx = {
        enable = false; # TODO: enable this when you want to test all the configs
        virtualHosts = {
          ${config.apps.headscale.hostname} = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
          };
          ${config.apps.jellyfin.hostname} = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://localhost:8096";
          };
          ${config.apps.forgejo.hostname} = {
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

    networking.firewall.allowedTCPPorts = [53 2049 3000 8081];

    environment.systemPackages = [
      config.services.headscale.package
      pkgs.jellyfin
      pkgs.jellyfin-web
      pkgs.jellyfin-ffmpeg
    ];
  };
}
