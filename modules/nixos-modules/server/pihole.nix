{
  lib,
  config,
  inputs,
  ...
}: let
  dnsPort = 53;
  webPort = 8090;
in {
  options.host.pihole = {
    enable = lib.mkEnableOption "should home-assistant be enabled on this computer";
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pihole";
    };
    image = lib.mkOption {
      type = lib.types.str;
      default = "pihole/pihole:latest";
      description = "container image to use for pi-hole";
    };
    # piholeStateDirectory = {
    #   type = lib.types.str;
    #   default = "${config.host.pihole.directory}/pihole";
    # };
    # tailscaleStateDirectory = {
    #   type = lib.types.str;
    #   default = "${config.host.pihole.directory}/tailscale";
    # };
    # piholeImage = lib.mkOption {
    #   type = lib.types.str;
    #   default = "pihole/pihole:2024.07.0";
    #   description = "container image to use for pi-hole";
    # };
    # tailscaleImage = lib.mkOption {
    #   type = lib.types.str;
    #   default = "tailscale/tailscale:latest";
    #   description = "container image to use for pi-holes tail scale";
    # };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "ip address to use for pi-hole";
    };
  };
  config = lib.mkIf config.host.pihole.enable (lib.mkMerge [
    {
      host.podman.enable = true;
      sops = {
        secrets = {
          "services/pi-hole" = {
            sopsFile = "${inputs.secrets}/defiant-services.yaml";
          };
          # "wireguard-keys/tailscale-authkey/pihole" = {
          #   sopsFile = "${inputs.secrets}/wireguard-keys.yaml";
          # };
        };
        templates."pihole.env".content = ''
          FTLCONF_webserver_api_password=${config.sops.placeholder."services/pi-hole"}
        '';
      };
      systemd = {
        tmpfiles.rules = [
          "d ${config.host.pihole.directory} 755 pihole pihole -" # is /home/docker/pihole on old system
          # "d ${config.host.pihole.piholeStateDirectory} 755 pihole pihole -"
          # "d ${config.host.pihole.tailscaleStateDirectory} 755 pihole pihole -"
        ];

        services = {
          "podman-pihole" = {
            serviceConfig = {
              Restart = lib.mkOverride 500 "always";
            };
            # after = [
            #   "podman-network-macvlan.service"
            # ];
            # requires = [
            #   "podman-network-macvlan.service"
            # ];
            partOf = [
              "podman-compose-root.target"
            ];
            wantedBy = [
              "podman-compose-root.target"
            ];
          };
        };
      };

      services.resolved.enable = false;

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
                FTLCONF_webserver_port = toString webPort;
                PIHOLE_UID = toString config.users.users.pihole.uid;
                PIHOLE_GID = toString config.users.groups.pihole.gid;
              };
              environmentFiles = [
                config.sops.templates."pihole.env".path
              ];
              log-driver = "journald";
              extraOptions = [
                "--network=host"
                # "--network=container:${tailscale container id}"
              ];
            };
            # ts-pihole = {
            #   image = config.host.pihole.tailscaleImage;
            #   volumes = "${config.host.pihole.tailscaleStateDirectory}:/var/lib/tailscale";
            #   environment = {
            #     TS_ACCEPT_DNS = "false";
            #     TS_HOSTNAME = "pihole";
            #     TS_STATE_DIR = "/var/lib/tailscale";
            #     TS_USERSPACE = "false";
            #     TS_EXTRA_ARGS = "--advertise-tags=tag:container";
            #   };
            #   environmentFiles = [
            #     config.sops.templates."tailscale-pihole.env".path
            #   ];
            #   devices = [
            #     "/dev/net/tun:/dev/net/tun"
            #   ];
            #   extraOptions = [
            #     "--ip=${config.host.pihole.ip}"
            #     "--network=macvlan"
            #   ];
            # };
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
