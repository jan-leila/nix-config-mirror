{
  config,
  lib,
  ...
}: let
  tailscale_data_directory = "/var/lib/tailscale";
in {
  options.host.tailscale = {
    enable = lib.mkEnableOption "should tailscale be enabled on this computer";
  };

  config = lib.mkIf config.services.tailscale.enable (
    lib.mkMerge [
      {
        # any configs we want shared between all machines
      }
      (lib.mkIf config.host.impermanence.enable {
        environment.persistence = {
          "/persist/system/root" = {
            enable = true;
            hideMounts = true;
            directories = [
              {
                directory = tailscale_data_directory;
                user = "jellyfin";
                group = "jellyfin";
              }
            ];
          };
        };
      })
    ]
  );
}
