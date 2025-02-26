{
  config,
  lib,
  ...
}: {
  options = {
    host.network_storage.nfs = {
      enable = lib.mkEnableOption "is this server going to export network storage as nfs shares";
      port = lib.mkOption {
        type = lib.types.int;
        default = 2049;
        description = "port that nfs will run on";
      };
      directories = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum (
            builtins.map (
              directory: directory.folder
            )
            config.host.network_storage.directories
          )
        );
        description = "list of exported directories to be exported via nfs";
      };
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(config.host.network_storage.nfs.enable && !config.host.network_storage.enable);
          message = "nfs cant be enabled with network storage disabled";
        }
      ];
    }
    (
      lib.mkIf (config.host.network_storage.nfs.enable && config.host.network_storage.enable) {
        services.nfs.server = {
          enable = true;
          exports = lib.strings.concatLines (
            builtins.map (
              directory: "${directory._directory} 100.64.0.0/10(rw,sync,no_subtree_check,crossmnt)"
            )
            (
              builtins.filter (
                directory: lib.lists.any (target: target == directory.folder) config.host.network_storage.nfs.directories
              )
              config.host.network_storage.directories
            )
          );
        };
        networking.firewall.allowedTCPPorts = [
          config.host.network_storage.nfs.port
        ];
      }
    )
  ];
}
