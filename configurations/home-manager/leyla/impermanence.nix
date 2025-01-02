{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.host.impermanence.enable {
    home.persistence."/persist/home/leyla" = {
      directories = [
        "desktop"
        "downloads"
        "documents"
        ".ssh"
        ".config/gnome-initial-setup-done"
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
      ];
    };
  };
}
