{
  config,
  lib,
  ...
}: let
  mountDir = "/mnt/sync";
  configDir = "/etc/syncthing";
in {
  options.host.sync = {
    enable = lib.mkEnableOption "should sync thing be enabled on this device";
    devices = {
      ceder = {
        autoAcceptFolders = lib.mkEnableOption "should sync thing auto accept folders from ceder";
      };
      coven = {
        autoAcceptFolders = lib.mkEnableOption "should sync thing auto accept folders from coven";
      };
      twilight = {
        autoAcceptFolders = lib.mkEnableOption "should sync thing auto accept folders from twilight";
      };
      horizon = {
        autoAcceptFolders = lib.mkEnableOption "should sync thing auto accept folders from horizon";
      };
      shale = {
        autoAcceptFolders = lib.mkEnableOption "should sync thing auto accept folders from shale";
      };
    };
    folders = {
      share = {
        enable = lib.mkEnableOption "should the share folder by synced";
        calendar = {
          enable = lib.mkEnableOption "should the calendar folder be synced";
        };
      };
      leyla = {
        documents = {
          enable = lib.mkEnableOption "should the documents folder be synced";
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
          configDir = configDir;
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            devices = {
              ceder = {
                id = "MGXUJBS-7AENXHB-7YQRNWG-QILKEJD-5462U2E-WAQW4R4-I2TVK5H-SMK6LAA";
                autoAcceptFolders = config.host.sync.devices.ceder.autoAcceptFolders;
              };
              coven = {
                id = "QGU7NN6-OMXTWVA-YCZ73S5-2O7ECTS-MUCTN4M-YH6WLEL-U4U577I-7PBNCA5";
                autoAcceptFolders = config.host.sync.devices.coven.autoAcceptFolders;
              };
              defiant = lib.mkIf (config.networking.hostName != "defiant") {
                id = "3R6E6Y4-2F7MF2I-IGB4WE6-A3SQSMV-LIBYSAM-2OXHHU2-KJ6CGIV-QNMCPAR";
              };
              twilight = lib.mkIf (config.networking.hostName != "twilight") {
                id = "UDIYL7V-OAZ2BI3-EJRAWFB-GZYVDWR-JNUYW3F-FFQ35MU-XBTGWEF-QD6K6QN";
                autoAcceptFolders = config.host.sync.devices.twilight.autoAcceptFolders;
              };
              horizon = lib.mkIf (config.networking.hostName != "horizon") {
                id = "OGPAEU6-5UR56VL-SP7YC4Y-IMVCRTO-XFD4CYN-Z6T5TZO-PFZNAT6-4MKWPQS";
                autoAcceptFolders = config.host.sync.devices.horizon.autoAcceptFolders;
              };
              shale = {
                id = "AOAXEVD-QJ2IVRA-6G44Q7Q-TGUPXU2-FWWKOBH-DPKWC5N-LBAEHWJ-7EQF4AM";
                autoAcceptFolders = config.host.sync.devices.shale.autoAcceptFolders;
              };
            };
            folders = let
              ceder = "ceder";
              coven = "coven";
              shale = "shale";
              defiant = lib.mkIf (config.networking.hostName != "defiant") "defiant";
              twilight = lib.mkIf (config.networking.hostName != "twilight") "twilight";
              horizon = lib.mkIf (config.networking.hostName != "horizon") "horizon";
            in
              lib.mkMerge [
                config.host.sync.folders.extraFolders
                (lib.mkIf config.host.sync.folders.leyla.documents.enable {
                  "documents" = {
                    id = "hvrj0-9bm1p";
                    path = "${mountDir}/leyla/documents";
                    devices = [
                      defiant
                      ceder
                      coven
                      twilight
                      horizon
                    ];
                  };
                })
                (lib.mkIf config.host.sync.folders.share.calendar.enable {
                  "calendar" = {
                    id = "8oatl-1rv6w";
                    path = "${mountDir}/default/calendar";
                    devices = [
                      defiant
                      ceder
                      shale
                    ];
                  };
                })
                (lib.mkIf config.host.sync.folders.leyla.notes.enable {
                  "notes" = {
                    id = "dwbuv-zffnf";
                    path = "${mountDir}/leyla/notes";
                    devices = [
                      defiant
                      ceder
                    ];
                  };
                })
                (lib.mkIf config.host.sync.folders.share.enable {
                  "share" = {
                    id = "73ot0-cxmkx";
                    path = "${mountDir}/default/share";
                    devices = [
                      defiant
                      ceder
                      coven
                      twilight
                      horizon
                      shale
                    ];
                  };
                })
              ];
          };
        };
      }

      (lib.mkIf config.host.impermanence.enable {
        assertions = [
          {
            assertion = config.services.syncthing.configDir == configDir;
            message = "syncthing config dir does not match persistence";
          }
        ];
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
              {
                directory = configDir;
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
