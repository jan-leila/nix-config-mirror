{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.home-manager.users.leyla;
in {
  config = {
    nixpkgs.config.allowUnfree = true;

    sops.secrets = lib.mkIf (cfg.isFullUser || cfg.isThinUser) {
      "passwords/leyla" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
    };

    users.users.leyla = (
      if (cfg.isFullUser || cfg.isThinUser)
      then {
        isNormalUser = true;
        extraGroups = lib.mkMerge [
          ["networkmanager" "wheel"]
          (
            lib.mkUnless cfg.isThinUser ["adbusers"]
          )
        ];

        hashedPasswordFile = config.sops.secrets."passwords/leyla".path;

        openssh = {
          authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHeItmt8TRW43uNcOC+eIurYC7Eunc0V3LGocQqLaYj leyla@horizon"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBiZkg1c2aaNHiieBX4cEziqvJVj9pcDfzUrKU/mO0I leyla@twilight"
          ];
        };
      }
      else {
        isSystemUser = true;
      }
    );

    services = {
      ollama = {
        enable = true;
        acceleration = lib.mkIf cfg.hasGPU "cuda";
      };

      # TODO: this should reference the home directory from the user config
      openssh.hostKeys = [
        {
          comment = "leyla@" + config.networking.hostName;
          path = "/home/leyla/.ssh/leyla_" + config.networking.hostName + "_ed25519";
          rounds = 100;
          type = "ed25519";
        }
      ];
    };

    programs = {
      steam = lib.mkIf cfg.isFullUser {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated ServerServer
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };

      noisetorch.enable = cfg.isFullUser;

      adb.enable = cfg.isFullUser;
    };
  };
}
