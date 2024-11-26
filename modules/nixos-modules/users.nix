{
  lib,
  config,
  inputs,
  ...
}: let
  SOPS_AGE_KEY_DIRECTORY = import ../../const/sops_age_key_directory.nix;

  host = config.host;

  principleUsers = host.principleUsers;
  terminalUsers = host.terminalUsers;
  # normalUsers = host.normalUsers;

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
  config = {
    # principle users are by definition trusted
    nix.settings.trusted-users = builtins.map (user: user.name) principleUsers;

    # we should only be able to ssh into principle users of a computer who are also set up for terminal access
    services.openssh.settings.AllowUsers = builtins.map (user: user.name) (lib.lists.intersectLists terminalUsers principleUsers);

    # we need to set up env variables to nix can find keys to decrypt passwords on rebuild
    environment = {
      sessionVariables = {
        SOPS_AGE_KEY_DIRECTORY = SOPS_AGE_KEY_DIRECTORY;
        SOPS_AGE_KEY_FILE = "${SOPS_AGE_KEY_DIRECTORY}/key.txt";
      };
    };

    # set up user passwords
    sops = {
      defaultSopsFormat = "yaml";
      gnupg.sshKeyPaths = [];

      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        sshKeyPaths = [];
        # generateKey = true;
      };

      secrets = {
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
    };

    users = {
      mutableUsers = false;
      users = {
        leyla = {
          uid = lib.mkForce uids.leyla;
          name = lib.mkForce host.users.leyla.name;
          description = "Leyla";
          extraGroups =
            (lib.lists.optionals host.users.leyla.isNormalUser ["networkmanager"])
            ++ (lib.lists.optionals host.users.leyla.isPrincipleUser ["wheel" "dialout"])
            ++ (lib.lists.optionals host.users.leyla.isDesktopUser ["adbusers"]);
          hashedPasswordFile = config.sops.secrets."passwords/leyla".path;
          isNormalUser = host.users.leyla.isNormalUser;
          isSystemUser = !host.users.leyla.isNormalUser;
          group = config.users.users.leyla.name;
        };

        ester = {
          uid = lib.mkForce uids.ester;
          name = lib.mkForce host.users.ester.name;
          description = "Ester";
          extraGroups = lib.optionals host.users.ester.isNormalUser ["networkmanager"];
          hashedPasswordFile = config.sops.secrets."passwords/ester".path;
          isNormalUser = host.users.ester.isNormalUser;
          isSystemUser = !host.users.ester.isNormalUser;
          group = config.users.users.ester.name;
        };

        eve = {
          uid = lib.mkForce uids.eve;
          name = lib.mkForce host.users.eve.name;
          description = "Eve";
          extraGroups = lib.optionals host.users.eve.isNormalUser ["networkmanager"];
          hashedPasswordFile = config.sops.secrets."passwords/eve".path;
          isNormalUser = host.users.eve.isNormalUser;
          isSystemUser = !host.users.eve.isNormalUser;
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