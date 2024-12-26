{
  config,
  lib,
  ...
}: let
  export_directory = config.host.network_storage.export_directory;
in {
  imports = [
    ./nfs.nix
  ];

  options = {
    host.network_storage = {
      enable = lib.mkEnableOption "is this machine going to export network storage";
      export_directory = lib.mkOption {
        type = lib.types.path;
        description = "what are exports going to be stored in";
        default = "/exports";
      };
      directories = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule ({config, ...}: {
          options = {
            folder = lib.mkOption {
              type = lib.types.str;
              description = "what is the name of this export directory";
            };
            bind = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              description = "is this directory bound to anywhere";
              default = null;
            };
            user = lib.mkOption {
              type = lib.types.str;
              description = "what user owns this directory";
              default = "nouser";
            };
            group = lib.mkOption {
              type = lib.types.str;
              description = "what group owns this directory";
              default = "nogroup";
            };
            _directory = lib.mkOption {
              internal = true;
              readOnly = true;
              type = lib.types.path;
              default = "${export_directory}/${config.folder}";
            };
          };
        }));
        description = "list of directory names to export";
      };
    };
  };

  config = lib.mkIf config.host.network_storage.enable (lib.mkMerge [
    {
      # create any folders that we need to have for our exports
      systemd.tmpfiles.rules =
        [
          "d ${config.host.network_storage.export_directory} 2770 root root -"
        ]
        ++ (
          builtins.map (
            directory: "d ${directory._directory} 2770 ${directory.user} ${directory.group}"
          )
          config.host.network_storage.directories
        );

      # set up any bind mounts that we need for our exports
      fileSystems = builtins.listToAttrs (
        builtins.map (directory:
          lib.attrsets.nameValuePair directory._directory {
            device = directory.bind;
            options = ["bind"];
          }) (
          builtins.filter (directory: directory.bind != null) config.host.network_storage.directories
        )
      );
    }
    (lib.mkIf config.host.impermanence.enable {
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          config.host.network_storage.export_directory
        ];
      };
    })
  ]);
}
