{
  lib,
  osConfig,
  ...
}: {
  home.persistence."/persist/home/leyla" = lib.mkIf osConfig.host.impermanence.enable {
    directories = [
      "desktop"
      "downloads"
      "documents"
      ".ssh"
      ".nixops"
      ".local/share/keyrings"
      ".local/share/direnv"
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
    ];
    # files = [
    #   ".screenrc"
    # ];
    allowOther = true;
  };
}
