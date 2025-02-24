{
  inputs,
  config,
  ...
}: {
  imports = [
    ./monitors.nix
  ];

  nixpkgs.config.allowUnfree = true;

  sops.secrets = {
    "wireguard-keys/tailscale-authkey/twilight" = {
      sopsFile = "${inputs.secrets}/wireguard-keys.yaml";
    };
  };
  host = {
    users = {
      leyla = {
        isDesktopUser = true;
        isTerminalUser = true;
        isPrincipleUser = true;
      };
      eve.isDesktopUser = true;
    };
    hardware = {
      piperMouse.enable = true;
      viaKeyboard.enable = true;
      openRGB.enable = true;
      graphicsAcceleration.enable = true;
    };
  };

  services = {
    ollama = {
      enable = true;

      loadModels = [
        "deepseek-coder:6.7b"
        "deepseek-r1:8b"
        "deepseek-r1:32b"
      ];
    };

    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."wireguard-keys/tailscale-authkey/twilight".path;
      useRoutingFeatures = "both";
    };
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # enabled virtualisation for docker
  # virtualisation.docker.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
