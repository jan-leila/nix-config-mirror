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
    sops.secrets = {
      "services/pi-hole" = {
        sopsFile = ../../secrets/defiant-services.yaml;
      };
    };

    # Runtime
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
      };
    };
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.pihole = {
      image = "pihole/pihole:2024.07.0";
      hostname = "pihole";
      volumes = [
        "/home/pihole:/etc/pihole:rw" # TODO; set this based on configs
        "${config.sops.secrets."services/pi-hole".path}:/var/lib/pihole/webpassword.txt"
      ];
      environment = {
        TZ = config.time.timeZone;
        WEBPASSWORD_FILE = "/var/lib/pihole/webpassword.txt";
        PIHOLE_UID = toString config.users.users.pihole.uid;
        PIHOLE_GID = toString config.users.groups.pihole.gid;
      };
      log-driver = "journald";
      extraOptions = [
        "--ip=192.168.1.201" # TODO: set this to some ip address from configs
        "--network=macvlan"
      ];
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
          path = [ pkgs.podman ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "podman network rm -f macvlan";
          };
          # TODO: check subnet against pi-hole ip address
          # TODO: make lan configurable
          # TODO: make parent interface configurable
          script = ''
            podman network inspect macvlan || podman network create --driver macvlan --subnet 192.168.1.0/24 --gateway 192.168.1.1 --opt parent=bond0 macvlan
          '';
          partOf = [ "podman-compose-root.target" ];
          wantedBy = [ "podman-compose-root.target" ];
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
          wantedBy = [ "multi-user.target" ];
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

    networking.firewall.allowedTCPPorts = [53 2049 3000 8081];

    environment.systemPackages = [
      config.services.headscale.package
      pkgs.jellyfin
      pkgs.jellyfin-web
      pkgs.jellyfin-ffmpeg
    ];
  };
}
