{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.nixos.users.leyla;
in {
  options.nixos.users.leyla = {
    isDesktopUser = lib.mkEnableOption "install applications intended for desktop use";
    isTerminalUser = lib.mkEnableOption "install applications intended for terminal use";
    hasGPU = lib.mkEnableOption "installs gpu intensive programs";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    sops.secrets = lib.mkIf (cfg.isDesktopUser || cfg.isTerminalUser) {
      "passwords/leyla" = {
        neededForUsers = true;
        sopsFile = "${inputs.secrets}/user-passwords.yaml";
      };
    };

    users.users.leyla = (
      if (cfg.isDesktopUser || cfg.isTerminalUser)
      then {
        isNormalUser = true;
        extraGroups = (
          ["networkmanager" "wheel"]
          ++ lib.lists.optional (!cfg.isTerminalUser) "adbusers"
        );

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
      # ollama = {
      #   enable = cfg.hasGPU;
      #   acceleration = "cuda";
      # };

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
      steam = lib.mkIf cfg.isDesktopUser {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated ServerServer
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };

      noisetorch.enable = cfg.isDesktopUser;

      adb.enable = cfg.isDesktopUser;
    };
  };
}
