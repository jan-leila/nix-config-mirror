{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  jellyfinPort = 8096;
  nfsPort = 2049;
  dnsPort = 53;
  httpPort = 80;
  httpsPort = 443;
  isDebug = false;
in {
  imports = [];

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
        directory = {
          root = lib.mkOption {
            type = lib.types.str;
            description = "directory that pihole will be hosted at";
            default = "/var/lib/pihole";
          };
          data = lib.mkOption {
            type = lib.types.str;
            description = "directory that pihole data will be hosted at";
            default = "${config.apps.pihole.directory.root}/data";
          };
        };
      };
      headscale = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that headscale will be hosted at";
          default = "headscale";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that headscale will be hosted at";
          default = "${config.apps.headscale.subdomain}.${config.apps.base_domain}";
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
          description = "hostname that jellyfin will be hosted at";
          default = "${config.apps.jellyfin.subdomain}.${config.apps.base_domain}";
        };
        mediaDirectory = lib.mkOption {
          type = lib.types.str;
          description = "directory that jellyfin will be at";
          default = "/home/jellyfin";
        };
      };
      forgejo = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that forgejo will be hosted at";
          default = "forgejo";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that forgejo will be hosted at";
          default = "${config.apps.forgejo.subdomain}.${config.apps.base_domain}";
        };
      };
      home-assistant = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that home-assistant will be hosted at";
          default = "home-assistant";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that home-assistant will be hosted at";
          default = "${config.apps.home-assistant.subdomain}.${config.apps.base_domain}";
        };
      };
      searx = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that searx will be hosted at";
          default = "search";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that searx will be hosted at";
          default = "${config.apps.searx.subdomain}.${config.apps.base_domain}";
        };
      };
      nextcloud = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          description = "subdomain of base domain that nextcloud will be hosted at";
          default = "nextcloud";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "hostname that nextcloud will be hosted at";
          default = "${config.apps.nextcloud.subdomain}.${config.apps.base_domain}";
        };
      };
    };
  };

  config = {
    sops.secrets = {
      "services/pi-hole" = {
        sopsFile = "${inputs.secrets}/defiant-services.yaml";
      };
      "services/searx" = {
        sopsFile = "${inputs.secrets}/defiant-services.yaml";
      };
      "services/nextcloud_adminpass" = {
        sopsFile = "${inputs.secrets}/defiant-services.yaml";
        owner = config.users.users.nextcloud.name;
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
              "${config.apps.pihole.directory.data}:/etc/pihole:rw"
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

    # TODO: dynamic users
    systemd = {
      tmpfiles.rules = [
        "d ${config.apps.jellyfin.mediaDirectory} 2775 jellyfin jellyfin_media -" # is /home/docker/jellyfin/media on existing server
        "d ${config.apps.pihole.directory.root} 755 pihole pihole -" # is /home/docker/pihole on old system
        "d ${config.apps.pihole.directory.data} 755 pihole pihole -" # is /home/docker/pihole on old system
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
        # nextcloud-setup = {
        #   after = ["network.target"];
        # };
        headscale = {
          after = ["postgresql.service"];
          requires = ["postgresql.service"];
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
        ensureUsers = [
          {
            name = "postgres";
          }
          {
            name = "forgejo";
            ensureDBOwnership = true;
          }
          {
            name = "headscale";
            ensureDBOwnership = true;
          }
        ];
        ensureDatabases = [
          "forgejo"
          "headscale"
          # "nextcloud"
        ];
        identMap = ''
          # ArbitraryMapName systemUser DBUser

          # Administration Users
          superuser_map      postgres  postgres
          superuser_map      root      postgres
          superuser_map      leyla     postgres

          # Client Users
          superuser_map      forgejo   forgejo
          superuser_map      headscale headscale
        '';
        # configuration here lets users access the db that matches their name and lets user postgres access everything
        authentication = pkgs.lib.mkOverride 10 ''
          # type database DBuser    origin-address auth-method   optional_ident_map
          local  all      postgres                 peer          map=superuser_map
          local  sameuser all                      peer          map=superuser_map
        '';
      };

      headscale = {
        enable = true;
        user = "headscale";
        group = "headscale";
        address = "0.0.0.0";
        port = 8080;
        settings = {
          server_url = "https://${config.apps.headscale.hostname}";
          dns.base_domain = "clients.${config.apps.headscale.hostname}";
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

      jellyfin = {
        enable = true;
      };

      forgejo = {
        enable = true;
        database = {
          type = "postgres";
          socket = "/run/postgresql";
        };
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = config.apps.forgejo.hostname;
            HTTP_PORT = 8081;
          };
        };
      };

      home-assistant = {
        enable = true;
        config.http = {
          server_port = 8082;
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1"];
          ip_ban_enabled = true;
          login_attempts_threshold = 10;
        };
      };

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

      # nextcloud here is built using its auto setup mysql db because it was not playing nice with postgres
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud30;
        hostName = config.apps.nextcloud.hostname;
        config = {
          adminpassFile = config.sops.secrets."services/nextcloud_adminpass".path;
        };
      };

      nginx = {
        enable = true;
        virtualHosts = {
          ${config.apps.headscale.hostname} = {
            # forceSSL = true;
            # enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
          };
          ${config.apps.jellyfin.hostname} = {
            # forceSSL = true;
            # enableACME = true;
            locations."/".proxyPass = "http://localhost:${toString jellyfinPort}";
          };
          ${config.apps.forgejo.hostname} = {
            # forceSSL = true;
            # enableACME = true;
            locations."/".proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
          };
          ${config.apps.home-assistant.hostname} = {
            # forceSSL = true;
            # enableACME = true;
            locations."/".proxyPass = "http://localhost:${toString config.services.home-assistant.config.http.server_port}";
          };
          ${config.apps.searx.hostname} = {
            # forceSSL = true;
            # enableACME = true;
            locations."/".proxyPass = "http://localhost:${toString config.services.searx.settings.server.port}";
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "jan-leila@protonmail.com";
    };

    networking.firewall.allowedTCPPorts =
      [
        httpPort
        httpsPort
        dnsPort
        nfsPort
      ]
      ++ (lib.optional isDebug [
        jellyfinPort
        config.services.headscale.port
        config.services.forgejo.settings.server.HTTP_PORT
        config.services.home-assistant.config.http.server_port
        config.services.postgresql.settings.port
        config.services.searx.settings.server.port
      ]);

    environment.systemPackages = [
      config.services.headscale.package
      pkgs.jellyfin
      pkgs.jellyfin-web
      pkgs.jellyfin-ffmpeg
    ];
  };
}
