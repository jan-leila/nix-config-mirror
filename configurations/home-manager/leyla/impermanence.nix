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
        ".bash_history" # keep shell history around
        ".local/share/recently-used.xbel" # gnome recently viewed files
      ];
      allowOther = true;
    };
  };
}
