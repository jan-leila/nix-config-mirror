{
  config,
  lib,
  ...
}: let
  mountDir = "/mnt/sync";
in {
  options.host.sync = {
    enable = lib.mkEnableOption "should sync thing be enabled on this device";
    folders = {
      share = {
        enable = lib.mkEnableOption "should the share folder by synced";
      };
      leyla = {
        documents = {
          enable = lib.mkEnableOption "should the documents folder be synced";
        };
        calendar = {
          enable = lib.mkEnableOption "should the calendar folder be synced";
        };
        notes = {
          enable = lib.mkEnableOption "should the notes folder by synced";
        };
      };
      extraFolders = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({...}: {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
            };
            devices = lib.mkOption {
              type = lib.types.listof lib.types.str;
            };
          };
        }));
        default = {};
      };
    };
  };

  config = lib.mkMerge [
    {
      systemd = lib.mkIf config.services.syncthing.enable {
        tmpfiles.rules = [
          "d ${mountDir} 2755 syncthing syncthing -"
          "d ${config.services.syncthing.dataDir} 775 syncthing syncthing -"
          "d ${config.services.syncthing.configDir} 755 syncthing syncthing -"
        ];
      };
    }
    (lib.mkIf config.host.sync.enable (lib.mkMerge [
      {
        services.syncthing = {
          enable = true;
          user = "syncthing";
          group = "syncthing";
          dataDir = "${mountDir}/default";
          configDir = "/etc/syncthing";
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            devices = {
              ceder = {
                id = "MGXUJBS-7AENXHB-7YQRNWG-QILKEJD-5462U2E-WAQW4R4-I2TVK5H-SMK6LAA";
              };
              coven = {
                id = "QGU7NN6-OMXTWVA-YCZ73S5-2O7ECTS-MUCTN4M-YH6WLEL-U4U577I-7PBNCA5";
              };
              defiant = lib.mkIf (config.networking.hostName != "defiant") {
                id = "TQGGO5F-PUXQYVV-LVVM7PR-Q4TKI6T-NR576PH-CFTVB4O-RP5LL6C-WKQMXQR";
              };
              twilight = lib.mkIf (config.networking.hostName != "twilight") {
                id = "UDIYL7V-OAZ2BI3-EJRAWFB-GZYVDWR-JNUYW3F-FFQ35MU-XBTGWEF-QD6K6QN";
              };
              horizon = lib.mkIf (config.networking.hostName != "horizon") {
                id = "OGPAEU6-5UR56VL-SP7YC4Y-IMVCRTO-XFD4CYN-Z6T5TZO-PFZNAT6-4MKWPQS";
              };
              shale = {
                id = "AOAXEVD-QJ2IVRA-6G44Q7Q-TGUPXU2-FWWKOBH-DPKWC5N-LBAEHWJ-7EQF4AM";
              };
            };
            folders = let
              ceder = "ceder";
              coven = "coven";
              shale = "shale";
              defiant = lib.mkIf (config.networking.hostName != "defiant") "defiant";
              twilight = lib.mkIf (config.networking.hostName != "twilight") "twilight";
              horizon = lib.mkIf (config.networking.hostName != "horizon") "horizon";
              allDevices = [
                defiant
                ceder
                coven
                twilight
                horizon
                shale
              ];
              leylaDevices = [
                defiant
                ceder
                coven
                twilight
                horizon
              ];
              superNoteTablets = [
                defiant
                ceder
                shale
              ];
            in
              lib.mkMerge [
                config.host.sync.folders.extraFolders
                (lib.mkIf config.host.sync.folders.leyla.documents.enable {
                  "documents" = {
                    id = "hvrj0-9bm1p";
                    path = "${mountDir}/leyla/documents";
                    devices = leylaDevices;
                  };
                })
                (lib.mkIf config.host.sync.folders.leyla.calendar.enable {
                  "calendar" = {
                    id = "8oatl-1rv6w";
                    path = "${mountDir}/leyla/calendar";
                    devices = superNoteTablets;
                  };
                })
                (lib.mkIf config.host.sync.folders.leyla.notes.enable {
                  "notes" = {
                    id = "dwbuv-zffnf";
                    path = "${mountDir}/leyla/notes";
                    devices = superNoteTablets;
                  };
                })
                (lib.mkIf config.host.sync.folders.share.enable {
                  "share" = {
                    id = "73ot0-cxmkx";
                    path = "${mountDir}/default/share";
                    devices = allDevices;
                  };
                })
              ];
          };
        };
      }

      (lib.mkIf config.host.impermanence.enable {
        environment.persistence = {
          "/persist/system/root" = {
            enable = true;
            hideMounts = true;
            directories = [
              {
                directory = mountDir;
                user = "syncthing";
                group = "syncthing";
              }
            ];
          };
        };
      })
    ]))
  ];
}
