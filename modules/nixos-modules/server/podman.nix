{
  lib,
  config,
  ...
}: {
  options.host.podman = {
    enable = lib.mkEnableOption "should home-assistant be enabled on this computer";
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
  };
  config = lib.mkIf config.host.podman.enable {
    systemd = {
      services = {
        # "podman-network-macvlan" = {
        #   path = [pkgs.podman];
        #   serviceConfig = {
        #     Type = "oneshot";
        #     RemainAfterExit = true;
        #     ExecStop = "podman network rm -f macvlan";
        #   };
        #   script = ''
        #     podman network inspect macvlan || podman network create --driver macvlan --subnet ${config.host.podman.macvlan.subnet} --gateway ${config.host.podman.macvlan.gateway} --opt parent=${config.host.podman.macvlan.networkInterface} macvlan
        #   '';
        #   partOf = ["podman-compose-root.target"];
        #   wantedBy = ["podman-compose-root.target"];
        # };
      };
      # disable computer sleeping
      targets = {
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

    virtualisation = {
      # Runtime
      podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        # defaultNetwork.settings = {
        #   # Required for container networking to be able to use names.
        #   dns_enabled = true;
        # };
      };

      oci-containers = {
        backend = "podman";
      };
    };
  };
}
