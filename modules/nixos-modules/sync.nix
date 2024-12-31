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

  config = {
    systemd = lib.mkIf config.services.syncthing.enable {
      tmpfiles.rules = [
        "d ${mountDir} 755 syncthing syncthing -"
        "d ${config.services.syncthing.dataDir} 755 syncthing syncthing -"
        "d ${config.services.syncthing.configDir} 755 syncthing syncthing -"
      ];
    };
    services.syncthing = {
      enable = config.host.sync.enable;
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
        };
        folders = lib.mkMerge [
          config.host.sync.folders.extraFolders
          (lib.mkIf config.host.sync.folders.leyla.documents.enable {
            "documents" = {
              id = "hvrj0-9bm1p";
              path = "/mnt/sync/leyla/documents";
              devices = ["ceder"];
            };
          })
          (lib.mkIf config.host.sync.folders.leyla.calendar.enable {
            "calendar" = {
              id = "8oatl-1rv6w";
              path = "/mnt/sync/leyla/calendar";
              devices = ["ceder"];
            };
          })
          (lib.mkIf config.host.sync.folders.leyla.notes.enable {
            "notes" = {
              id = "dwbuv-zffnf";
              path = "/mnt/sync/leyla/notes";
              devices = ["ceder"];
            };
          })
        ];
      };
    };
  };
}
