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
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
      ];
      files = [
        ".config/gnome-initial-setup-done" # gnome welcome message
        ".local/share/recently-used.xbel" # gnome recently viewed files
      ];
    };
  };
}
