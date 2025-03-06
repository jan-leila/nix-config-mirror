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
  normalUsers = host.normalUsers;

  uids = {
    leyla = 1000;
    eve = 1002;
    jellyfin = 2000;
    forgejo = 2002;
    adguardhome = 2003;
    hass = 2004;
    headscale = 2005;
    nextcloud = 2006;
    syncthing = 2007;
    ollama = 2008;
  };

  gids = {
    leyla = 1000;
    eve = 1002;
    users = 100;
    jellyfin_media = 2001;
    jellyfin = 2000;
    forgejo = 2002;
    adguardhome = 2003;
    hass = 2004;
    headscale = 2005;
    nextcloud = 2006;
    syncthing = 2007;
    ollama = 2008;
  };

  users = config.users.users;
  leyla = users.leyla.name;
  eve = users.eve.name;
in {
  config = lib.mkMerge [
    {
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

          adguardhome = {
            uid = lib.mkForce uids.adguardhome;
            isSystemUser = true;
            group = config.users.users.adguardhome.name;
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

          syncthing = {
            uid = lib.mkForce uids.syncthing;
            isSystemUser = true;
            group = config.users.users.syncthing.name;
          };

          ollama = {
            uid = lib.mkForce uids.ollama;
            isSystemUser = true;
            group = config.users.users.ollama.name;
          };
        };

        groups = {
          leyla = {
            gid = lib.mkForce gids.leyla;
            members = [
              leyla
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
              eve
            ];
          };

          jellyfin_media = {
            gid = lib.mkForce gids.jellyfin_media;
            members = [
              users.jellyfin.name
              leyla
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

          adguardhome = {
            gid = lib.mkForce gids.adguardhome;
            members = [
              users.adguardhome.name
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

          syncthing = {
            gid = lib.mkForce gids.syncthing;
            members = [
              users.syncthing.name
              leyla
              eve
            ];
          };

          ollama = {
            gid = lib.mkForce gids.ollama;
            members = [
              users.ollama.name
            ];
          };
        };
      };
    }
    (lib.mkIf config.host.impermanence.enable {
      boot.initrd.postResumeCommands = lib.mkAfter (
        lib.strings.concatLines (builtins.map (user: "zfs rollback -r rpool/local/home/${user.name}@blank")
          normalUsers)
      );

      systemd = {
        tmpfiles.rules =
          builtins.map (
            user: "d /persist/home/${user.name} 700 ${user.name} ${user.name} -"
          )
          normalUsers;
      };

      fileSystems = lib.mkMerge [
        {
          ${SOPS_AGE_KEY_DIRECTORY}.neededForBoot = true;
        }
        (
          builtins.listToAttrs (
            builtins.map (user:
              lib.attrsets.nameValuePair "/persist/home/${user.name}" {
                neededForBoot = true;
              })
            normalUsers
          )
        )
        (
          builtins.listToAttrs (
            builtins.map (user:
              lib.attrsets.nameValuePair "/home/${user.name}" {
                neededForBoot = true;
              })
            normalUsers
          )
        )
      ];

      host.storage.pool.extraDatasets = lib.mkMerge (
        [
          {
            # sops age key needs to be available to pre persist for user generation
            "local/system/sops" = {
              type = "zfs_fs";
              mountpoint = SOPS_AGE_KEY_DIRECTORY;
              options = {
                atime = "off";
                relatime = "off";
                canmount = "on";
              };
            };
          }
        ]
        ++ (
          builtins.map (user: {
            "local/home/${user.name}" = {
              type = "zfs_fs";
              mountpoint = "/home/${user.name}";
              options = {
                canmount = "on";
              };
              postCreateHook = ''
                zfs snapshot rpool/local/home/${user.name}@blank
              '';
            };
            "persist/home/${user.name}" = {
              type = "zfs_fs";
              mountpoint = "/persist/home/${user.name}";
            };
          })
          normalUsers
        )
      );
    })
  ];
}
