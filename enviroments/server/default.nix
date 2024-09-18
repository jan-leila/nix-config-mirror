{ config, ... }:
{
  imports = [
    ../common
  ];

  services = let
    headscaleDomain = "headscale.jan-leila.com";
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

    nginx = {
      enable = false; # TODO: enable this when you want to test all the configs
      virtualHosts = {
        ${headscaleDomain} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass =
              "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
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

  networking.firewall.allowedTCPPorts = [ 2049 ];

  environment.systemPackages = [ config.services.headscale.package ];
}