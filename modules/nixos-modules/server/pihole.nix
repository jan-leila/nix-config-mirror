{
  lib,
  config,
  inputs,
  ...
}: let
  dnsPort = 53;
in {
  options.host.pihole = {
    enable = lib.mkEnableOption "should home-assistant be enabled on this computer";
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pihole";
    };
    image = lib.mkOption {
      type = lib.types.str;
      default = "pihole/pihole:2024.07.0";
      description = "container image to use for pi-hole";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "ip address to use for pi-hole";
    };
  };
  config = lib.mkIf config.host.pihole.enable (lib.mkMerge [
    {
      host.podman.enable = true;
      sops.secrets = {
        "services/pi-hole" = {
          sopsFile = "${inputs.secrets}/defiant-services.yaml";
        };
      };
      systemd = {
        tmpfiles.rules = [
          "d ${config.host.pihole.directory} 755 pihole pihole -" # is /home/docker/pihole on old system
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
        };
      };

      # TODO: we need to have a tailscale container here and use that to define the network_mode of pihole container
      # TS_ACCEPT_DNS = "false";
      # TS_AUTHKEY = ${something from a secrets file???}
      # TS_HOSTNAME = "pihole";
      # TS_USERSPACE = "false";
      # TODO: volumes for tailnet container with impermanence config
      # https://tailscale.com/kb/1282/docker
      virtualisation = {
        oci-containers = {
          containers = {
            pihole = let
              passwordFileLocation = "/var/lib/pihole/webpassword.txt";
            in {
              image = config.host.pihole.image;
              volumes = [
                "${config.host.pihole.directory}:/etc/pihole:rw"
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
                "--ip=${config.host.pihole.ip}"
                "--network=macvlan"
              ];
            };
          };
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
            directory = config.host.pihole.directory;
            user = "pihole";
            group = "pihole";
          }
        ];
      };
    })
  ]);
}
