{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
  ];

  host = {
    users = {
      leyla = {
        isDesktopUser = true;
        isTerminalUser = true;
        isPrincipleUser = true;
      };
      eve.isDesktopUser = true;
    };
    sync = {
      enable = true;
      folders = {
        leyla = {
          documents.enable = true;
          calendar.enable = true;
          notes.enable = true;
        };
      };
    };
  };

  environment.systemPackages = [
    (pkgs.callPackage
      ./webtoon-dl.nix
      {})
  ];

  programs.adb.enable = true;

  sops.secrets = {
    "wireguard-keys/tailscale-authkey/horizon" = {
      sopsFile = "${inputs.secrets}/wireguard-keys.yaml";
    };
    # "wireguard-keys/proton/horizon" = {
    #   sopsFile = "${inputs.secrets}/wireguard-keys.yaml";
    # };
  };

  services = {
    # sudo fprintd-enroll
    fprintd = {
      enable = true;
    };
    ollama = {
      enable = true;

      loadModels = [
        "deepseek-coder:1.3b"
        "deepseek-r1:1.5b"
      ];
    };
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."wireguard-keys/tailscale-authkey/horizon".path;
    };
  };

  networking = {
    # wg-quick.interfaces = {
    #   proton = {
    #     # IP address of this machine in the *tunnel network*
    #     address = ["10.2.0.1/32"];

    #     listenPort = 51820;

    #     privateKeyFile = config.sops.secrets."wireguard-keys/proton/horizon".path;

    #     peers = [
    #       {
    #         publicKey = "Yu2fgynXUAASCkkrXWj76LRriFxKMTQq+zjTzyOKG1Q=";
    #         allowedIPs = ["0.0.0.0/0"];
    #         endpoint = "84.17.63.8:51820";
    #         persistentKeepalive = 25;
    #       }
    #       {
    #         publicKey = "OIPOmEDCJfuvTJ0dugMtY5L14gVpfpDdY3suniY5h3Y=";
    #         allowedIPs = ["0.0.0.0/0"];
    #         endpoint = "68.169.42.242:51820";
    #         persistentKeepalive = 25;
    #       }
    #       {
    #         publicKey = "uvEa3sdmi5d/OxozjecVIGQHgw4H42mNIX/QOulwDhs=";
    #         allowedIPs = ["0.0.0.0/0"];
    #       }
    #     ];
    #   };
    # };
  };

  # networking.extraHosts = ''
  #   # 192.168.1.204 jan-leila.com
  #   192.168.1.204 media.jan-leila.com
  #   # 192.168.1.204 drive.jan-leila.com
  #   192.168.1.204 git.jan-leila.com
  #   # 192.168.1.204 search.jan-leila.com
  # '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
