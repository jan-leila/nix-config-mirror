{
  lib,
  config,
  inputs,
  ...
}: let
  uids = {
    leyla = 1000;
    ester = 1001;
    eve = 1002;
    jellyfin = 2000;
    forgejo = 2002;
    pihole = 2003;
    hass = 2004;
    headscale = 2005;
    nextcloud = 2006;
  };

  gids = {
    leyla = 1000;
    ester = 1001;
    eve = 1002;
    users = 100;
    jellyfin_media = 2001;
    jellyfin = 2000;
    forgejo = 2002;
    pihole = 2003;
    hass = 2004;
    headscale = 2005;
    nextcloud = 2006;
  };

  users = config.users.users;
  leyla = users.leyla.name;
  ester = users.ester.name;
  eve = users.eve.name;
in {
  options.host.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      options = {
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
            User should install their applications
          '';
          defaultText = lib.literalExpression "config.host.users.\${name}.isNormalUser";
        };
      };
    }));
  };

  config = {
    # set up user passwords
    sops.secrets = {
      "passwords/leyla" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
      "passwords/ester" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
      "passwords/eve" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
    };

    users = {
      mutableUsers = false;
      users = {
        leyla = {
          uid = lib.mkForce uids.leyla;
          description = "Leyla";
          extraGroups =
            (lib.lists.optionals config.host.users.leyla.isNormalUser ["networkmanager" "wheel" "dialout"])
            ++ (lib.lists.optionals config.host.users.leyla.isDesktopUser ["adbusers"]);
          hashedPasswordFile = config.sops.secrets."passwords/leyla".path;
          isNormalUser = config.host.users.leyla.isNormalUser;
          isSystemUser = !config.host.users.leyla.isNormalUser;
          group = config.users.users.leyla.name;
        };

        ester = {
          uid = lib.mkForce uids.ester;
          description = "Ester";
          extraGroups = lib.optionals config.host.users.ester.isNormalUser ["networkmanager"];
          hashedPasswordFile = config.sops.secrets."passwords/ester".path;
          isNormalUser = config.host.users.ester.isNormalUser;
          isSystemUser = !config.host.users.ester.isNormalUser;
          group = config.users.users.ester.name;
        };

        eve = {
          uid = lib.mkForce uids.eve;
          description = "Eve";
          extraGroups = lib.optionals config.host.users.eve.isNormalUser ["networkmanager"];
          hashedPasswordFile = config.sops.secrets."passwords/eve".path;
          isNormalUser = config.host.users.eve.isNormalUser;
          isSystemUser = !config.host.users.eve.isNormalUser;
          group = config.users.users.eve.name;
        };

        jellyfin = {
          uid = lib.mkForce uids.jellyfin;
          isSystemUser = true;
          group = config.users.users.jellyfin.name;
        };

        forgejo = {
          uid = lib.mkForce uids.forgejo;
          isSystemUser = true;
          group = config.users.users.forgejo.name;
        };

        pihole = {
          uid = lib.mkForce uids.pihole;
          isSystemUser = true;
          group = config.users.users.pihole.name;
        };

        hass = {
          uid = lib.mkForce uids.hass;
          isSystemUser = true;
          group = config.users.users.hass.name;
        };

        headscale = {
          uid = lib.mkForce uids.headscale;
          isSystemUser = true;
          group = config.users.users.headscale.name;
        };

        nextcloud = {
          uid = lib.mkForce uids.nextcloud;
          isSystemUser = true;
          group = config.users.users.nextcloud.name;
        };
      };

      groups = {
        leyla = {
          gid = lib.mkForce gids.leyla;
          members = [
            leyla
          ];
        };

        ester = {
          gid = lib.mkForce gids.ester;
          members = [
            ester
          ];
        };

        eve = {
          gid = lib.mkForce gids.eve;
          members = [
            eve
          ];
        };

        users = {
          gid = lib.mkForce gids.users;
          members = [
            leyla
            ester
            eve
          ];
        };

        jellyfin_media = {
          gid = lib.mkForce gids.jellyfin_media;
          members = [
            users.jellyfin.name
            leyla
            ester
            eve
          ];
        };

        jellyfin = {
          gid = lib.mkForce gids.jellyfin;
          members = [
            users.jellyfin.name
            # leyla
          ];
        };

        forgejo = {
          gid = lib.mkForce gids.forgejo;
          members = [
            users.forgejo.name
            # leyla
          ];
        };

        pihole = {
          gid = lib.mkForce gids.pihole;
          members = [
            users.pihole.name
            # leyla
          ];
        };

        hass = {
          gid = lib.mkForce gids.hass;
          members = [
            users.hass.name
            # leyla
          ];
        };

        headscale = {
          gid = lib.mkForce gids.headscale;
          members = [
            users.headscale.name
            # leyla
          ];
        };

        nextcloud = {
          gid = lib.mkForce gids.nextcloud;
          members = [
            users.nextcloud.name
            # leyla
          ];
        };
      };
    };
  };
}
