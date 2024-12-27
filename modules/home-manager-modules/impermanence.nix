{
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.host.impermanence.enable {
    home.persistence."/persistent/home/${config.home.username}" = {
      directories = [
        ".ssh"
        "desktop"
        "downloads"
        "documents"
      ];
    };
  };
}
