{
  lib,
  config,
  ...
}: let
  dnsPort = 53;
in {
  options.host.adguardhome = {
    enable = lib.mkEnableOption "should home-assistant be enabled on this computer";
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/AdGuardHome/";
    };
  };
  config = lib.mkIf config.host.adguardhome.enable (lib.mkMerge [
    {
      services.adguardhome = {
        enable = true;
        mutableSettings = false;
        settings = {
          dns = {
            bootstrap_dns = [
              "1.1.1.1"
              "9.9.9.9"
            ];
            upstream_dns = [
              "dns.quad9.net"
            ];
          };
          filtering = {
            protection_enabled = true;
            filtering_enabled = true;

            parental_enabled = false; # Parental control-based DNS requests filtering.
            safe_search = {
              enabled = false; # Enforcing "Safe search" option for search engines, when possible.
            };
          };
          # The following notation uses map
          # to not have to manually create {enabled = true; url = "";} for every filter
          # This is, however, fully optional
          filters =
            map (url: {
              enabled = true;
              url = url;
            }) [
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
            ];
        };
      };

      networking.firewall.allowedTCPPorts = [
        dnsPort
      ];
    }
    (lib.mkIf config.host.impermanence.enable {
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          {
            directory = config.host.adguardhome.directory;
            user = "adguardhome";
            group = "adguardhome";
          }
        ];
      };
    })
  ]);
}
