{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    host.postgres = {
      enable = lib.mkEnableOption "enable postgres";
      extraAdminUsers = lib.mkOption {
        type = lib.types.attrsOf lib.types.submodule ({name, ...}: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = ''
                What should this users name on the system be
              '';
              defaultText = lib.literalExpression "config.host.users.\${name}.name";
            };
          };
        });
        default = {};
      };
      extraDatabaseUsers = lib.mkOption {
        type = lib.types.attrsOf lib.types.submodule ({name, ...}: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = ''
                What should this users name on the system be
              '';
              defaultText = lib.literalExpression "config.host.users.\${name}.name";
            };
          };
        });
        default = {};
      };
    };
  };

  config = lib.mkIf config.host.postgres.enable {
    services = {
      postgresql = {
        enable = true;
        ensureUsers =
          [
            {
              name = "postgres";
            }
          ]
          + (lib.attrsets.mapAttrsToList (user: {
              name = user.name;
              ensureDBOwnership = true;
            })
            config.host.postgres.extraDatabaseUsers);
        ensureDatabases = lib.attrsets.mapAttrsToList (user: user.name) config.host.postgres.extraDatabaseUsers;
        identMap =
          ''
            # ArbitraryMapName systemUser DBUser

            # Administration Users
            superuser_map      root      postgres
            superuser_map      postgres  postgres
          ''
          + (
            lib.strings.concatLines (lib.attrsets.mapAttrsToList (user: "superuser_map      ${user.name}   postgres") config.host.postgres.extraAdminUsers)
          )
          + ''

            # Client Users
          ''
          + (
            lib.strings.concatLines (lib.attrsets.mapAttrsToList (user: "superuser_map      ${user.name}   ${user.name}") config.host.postgres.extraDatabaseUsers)
          );
        # configuration here lets users access the db that matches their name and lets user postgres access everything
        authentication = pkgs.lib.mkOverride 10 ''
          # type database DBuser    origin-address auth-method   optional_ident_map
          local  all      postgres                 peer          map=superuser_map
          local  sameuser all                      peer          map=superuser_map
        '';
      };
    };
  };
}
