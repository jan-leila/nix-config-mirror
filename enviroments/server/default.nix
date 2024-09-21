{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common
  ];

  users = {
    groups = {
      jellyfin_media = {
        members = ["jellyfin" "leyla" "ester" "eve"];
      };

      jellyfin = {
        members = ["jellyfin" "leyla"];
      };

      # forgejo = {
      #   members = ["forgejo" "leyla"];
      # };
    };

    users = {
      jellyfin = {
        uid = 2000;
        group = "jellyfin";
        isSystemUser = true;
      };

      # forgejo = {
      #   uid = 2001;
      #   group = "forgejo";
      #   isSystemUser = true;
      # };
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/jellyfin 755 jellyfin jellyfin -"
    "d /home/jellyfin/media 775 jellyfin jellyfin_media -"
    "d /home/jellyfin/config 750 jellyfin jellyfin -"
    "d /home/jellyfin/cache 755 jellyfin jellyfin_media -"
    # "d /home/forgejo 750 forgejo forgejo -"
    # "d /home/forgejo/data 750 forgejo forgejo -"
  ];

  services = let
    jellyfinDomain = "jellyfin.jan-leila.com";
    headscaleDomain = "headscale.jan-leila.com";
    # forgejoDomain = "forgejo.jan-leila.com";
  in {
    nfs.server = {
      enable = true;
      exports = ''
        /home/leyla 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
        /home/eve   192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
        /home/ester 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
        /home/users 192.168.1.0/22(rw,sync,no_subtree_check,crossmnt)
      '';
    };

    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        server_url = "https://${headscaleDomain}";
        dns_config.base_domain = "jan-leila.com";
        logtail.enabled = false;
      };
    };

    jellyfin = {
      enable = true;
      user = "jellyfin";
      group = "jellyfin";
      dataDir = "/home/jellyfin/config"; # location on existing server: /home/docker/jellyfin/config
      cacheDir = "/home/jellyfin/cache"; # location on existing server: /home/docker/jellyfin/cache
      openFirewall = false;
    };

    # TODO: figure out what needs to be here
    # forgejo = {
    #   enable = true;
    #   database.type = "postgres";
    #   lfs.enable = true;
    #   settings = {
    #     server = {
    #       DOMAIN = forgejoDomain;
    #       HTTP_PORT = 8081;
    #     };
    #     service.DISABLE_REGISTRATION = true;
    #   };
    # };

    nginx = {
      enable = false; # TODO: enable this when you want to test all the configs
      virtualHosts = {
        ${headscaleDomain} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
        ${jellyfinDomain} = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://localhost:8096";
        };
        # ${forgejoDomain} = {
        #   forceSSL = true;
        #   enableACME = true;
        #   locations."/".proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        # };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jan-leila@protonmail.com";
  };

  # disable computer sleeping
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  networking.firewall.allowedTCPPorts = [2049];

  environment.systemPackages = [
    config.services.headscale.package
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
