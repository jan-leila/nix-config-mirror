{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
  ];

  nixpkgs.config.allowUnfree = true;

  host = {
    users = {
      leyla = {
        isDesktopUser = true;
        isTerminalUser = true;
        isPrincipleUser = true;
      };
      ester.isDesktopUser = true;
      eve.isDesktopUser = true;
    };
  };

  environment.systemPackages = [
    (pkgs.callPackage
      ./webtoon-dl.nix
      {})
  ];

  # enabled virtualisation for docker
  # virtualisation.docker = {
  #   enable = true;
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  # };
  # users.extraGroups.docker.members = ["leyla"];

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
