{
  config,
  lib,
  pkgs,
  ...
}: let
  dataDir = "/var/lib/postgresql/16";
  adminUsers = lib.lists.filter (user: user.isAdmin) (lib.attrsets.mapAttrsToList (_: user: user) config.host.postgres.extraUsers);
  clientUsers = lib.lists.filter (user: user.isClient) (lib.attrsets.mapAttrsToList (_: user: user) config.host.postgres.extraUsers);
  createUsers = lib.lists.filter (user: user.createUser) (lib.attrsets.mapAttrsToList (_: user: user) config.host.postgres.extraUsers);
  createDatabases = lib.attrsets.mapAttrsToList (_: user: user) config.host.postgres.extraDatabases;
in {
  options = {
    host.postgres = {
      enable = lib.mkEnableOption "enable postgres";
      extraUsers = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
            };
            isAdmin = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            isClient = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            createUser = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        }));
        default = {};
      };
      extraDatabases = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
            };
          };
        }));
        default = {};
      };
    };
  };

  config = lib.mkIf config.host.postgres.enable (lib.mkMerge [
    {
      services = {
        postgresql = {
          enable = true;
          package = pkgs.postgresql_16;
          ensureUsers =
            [
              {
                name = "postgres";
              }
            ]
            ++ (
              builtins.map (user: {
                name = user.name;
              })
              createUsers
            );
          ensureDatabases = builtins.map (database: database.name) createDatabases;
          identMap =
            ''
              # ArbitraryMapName systemUser DBUser

              # Administration Users
              superuser_map      root      postgres
              superuser_map      postgres  postgres
            ''
            + (
              lib.strings.concatLines (builtins.map (user: "superuser_map      ${user.name}   postgres") adminUsers)
            )
            + ''

              # Client Users
            ''
            + (
              lib.strings.concatLines (builtins.map (user: "user_map      ${user.name}   ${user.name}") clientUsers)
            );
          # configuration here lets users access the db that matches their name and lets user postgres access everything
          authentication = pkgs.lib.mkOverride 10 ''
            # type database DBuser    origin-address auth-method   optional_ident_map
            local  all      postgres                 peer          map=superuser_map
            local  sameuser all                      peer          map=user_map
          '';
        };
      };
    }

    (lib.mkIf config.host.impermanence.enable {
      assertions = [
        {
          assertion = config.services.postgresql.dataDir == dataDir;
          message = "postgres data directory does not match persistence";
        }
      ];
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          {
            directory = dataDir;
            user = "postgres";
            group = "postgres";
          }
        ];
      };
    })
  ]);
}
