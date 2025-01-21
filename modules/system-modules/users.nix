{
  lib,
  config,
  ...
}: let
  host = config.host;

  hostUsers = host.hostUsers;
  principleUsers = host.principleUsers;
in {
  options.host = {
    users = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule ({
        config,
        name,
        ...
      }: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = ''
              What should this users name on the system be
            '';
            defaultText = lib.literalExpression "config.host.users.\${name}.name";
          };
          isPrincipleUser = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              User should be configured as root and have ssh access
            '';
            defaultText = lib.literalExpression "config.host.users.\${name}.isPrincipleUser";
          };
          isDesktopUser = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              User should install their desktop applications
            '';
            defaultText = lib.literalExpression "config.host.users.\${name}.isDesktopUser";
          };
          isTerminalUser = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              User should install their terminal applications
            '';
            defaultText = lib.literalExpression "config.host.users.\${name}.isTerminalUser";
          };
          isNormalUser = lib.mkOption {
            type = lib.types.bool;
            default = config.isDesktopUser || config.isTerminalUser;
            description = ''
              User should install their applications and can log in
            '';
            defaultText = lib.literalExpression "config.host.users.\${name}.isNormalUser";
          };
        };
      }));
    };
    hostUsers = lib.mkOption {
      default = lib.attrsets.mapAttrsToList (_: user: user) host.users;
    };
    principleUsers = lib.mkOption {
      default = lib.lists.filter (user: user.isPrincipleUser) hostUsers;
    };
    normalUsers = lib.mkOption {
      default = lib.lists.filter (user: user.isNormalUser) hostUsers;
    };
    desktopUsers = lib.mkOption {
      default = lib.lists.filter (user: user.isDesktopUser) hostUsers;
    };
    terminalUsers = lib.mkOption {
      default = lib.lists.filter (user: user.isTerminalUser) hostUsers;
    };
  };

  config = {
    host.users = {
      leyla = {
        isPrincipleUser = lib.mkDefault false;
        isDesktopUser = lib.mkDefault false;
        isTerminalUser = lib.mkDefault false;
      };
      eve = {
        isPrincipleUser = lib.mkDefault false;
        isDesktopUser = lib.mkDefault false;
        isTerminalUser = lib.mkDefault false;
      };
    };

    assertions =
      (
        builtins.map (user: {
          assertion = !(user.isPrincipleUser && !user.isNormalUser);
          message = ''
            Non normal user ${user.name} can not be a principle user.
          '';
        })
        hostUsers
      )
      ++ [
        {
          assertion = (builtins.length principleUsers) > 0;
          message = ''
            At least one user must be a principle user.
          '';
        }
      ];
  };
}
