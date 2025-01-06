{
  lib,
  config,
  ...
}: let
  dataFile = "/var/lib/fail2ban/fail2ban.sqlite3";
in {
  options.host.fail2ban = {
    enable = lib.mkEnableOption "should fail 2 ban be enabled on this server";
  };

  config = lib.mkIf config.host.fail2ban.enable (lib.mkMerge [
    {
      services.fail2ban = {
        enable = true;
        maxretry = 5;
        ignoreIP = [
          # Whitelist local networks
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
        ];
        bantime = "24h"; # Ban IPs for one day on the first ban
        bantime-increment = {
          enable = true; # Enable increment of bantime after each violation
          formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
          maxtime = "168h"; # Do not ban for more than 1 week
          overalljails = true; # Calculate the ban time based on all the violations
        };
        jails = {
          nginx-iptables.settings = lib.mkIf config.services.nginx.enable {
            filter = "nginx";
            action = ''iptables-multiport[name=HTTP, port="http,https"]'';
            backend = "auto";
            failregex = "limiting requests, excess:.* by zone.*client: <HOST>";
            findtime = 600;
            bantime = 600;
            maxretry = 5;
          };
          jellyfin-iptables.settings = lib.mkIf config.services.jellyfin.enable {
            filter = "jellyfin";
            action = ''iptables-multiport[name=HTTP, port="http,https"]'';
            logpath = "${config.services.jellyfin.dataDir}/log/*.log";
            backend = "auto";
            failregex = "^.*Authentication request for .* has been denied \\\(IP: \"<ADDR>\"\\\)\\\.";
            findtime = 600;
            bantime = 600;
            maxretry = 5;
          };
          nextcloud-iptables.settings = lib.mkIf config.services.nextcloud.enable {
            filter = "nextcloud";
            action = ''iptables-multiport[name=HTTP, port="http,https"]'';
            logpath = "${config.services.nextcloud.datadir}/*.log";
            backend = "auto";
            failregex = ''
              ^{"reqId":".*","remoteAddr":".*","app":"core","message":"Login failed: '.*' \(Remote IP: '<HOST>'\)","level":2,"time":".*"}$
                          ^{"reqId":".*","level":2,"time":".*","remoteAddr":".*","user,:".*","app":"no app in context".*","method":".*","message":"Login failed: '.*' \(Remote IP: '<HOST>'\)".*}$
                          ^{"reqId":".*","level":2,"time":".*","remoteAddr":".*","user":".*","app":".*","method":".*","url":".*","message":"Login failed: .* \(Remote IP: <HOST>\).*}$
            '';
            findtime = 600;
            bantime = 600;
            maxretry = 5;
          };
          forgejo-iptables.settings = lib.mkIf config.services.forgejo.enable {
            filter = "forgejo";
            action = ''iptables-multiport[name=HTTP, port="http,https"]'';
            logpath = "${config.services.forgejo.stateDir}/log/*.log";
            backend = "auto";
            failregex = ".*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>";
            findtime = 600;
            bantime = 600;
            maxretry = 5;
          };
          home-assistant-iptables.settings = lib.mkIf config.services.home-assistant.enable {
            filter = "home-assistant";
            action = ''iptables-multiport[name=HTTP, port="http,https"]'';
            logpath = "${config.services.home-assistant.configDir}/*.log";
            backend = "auto";
            failregex = "^%(__prefix_line)s.*Login attempt or request with invalid authentication from <HOST>.*$";
            findtime = 600;
            bantime = 600;
            maxretry = 5;
          };
          # TODO; figure out if there is any fail2ban things we can do on searx
          # searx-iptables.settings = lib.mkIf config.services.searx.enable {};
        };
      };
    }
    (lib.mkIf config.host.impermanence.enable {
      assertions = [
        {
          assertion = config.services.fail2ban.daemonSettings.Definition.dbfile == dataFile;
          message = "fail2ban data file does not match persistence";
        }
      ];

      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        files = [
          dataFile
        ];
      };
    })
  ]);
}
