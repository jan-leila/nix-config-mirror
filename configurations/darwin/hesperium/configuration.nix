{...}: {
  host = {
    users = {
      leyla = {
        isDesktopUser = true;
        isTerminalUser = true;
        isPrincipleUser = true;
      };
      ester = {
        isPrincipleUser = true;
        isNormalUser = true;
      };
      eve.isNormalUser = false;
    };
  };

  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
