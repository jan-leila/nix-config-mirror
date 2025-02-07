{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {
      services.ollama = {
        group = "ollama";
        user = "ollama";
      };
    }
    (lib.mkIf config.host.impermanence.enable (lib.mkIf config.services.ollama.enable {
      environment.persistence."/persist/system/root" = {
        enable = true;
        hideMounts = true;
        directories = [
          {
            directory = config.services.ollama.models;
            user = config.services.ollama.user;
            group = config.services.ollama.group;
          }
        ];
      };
    }))
  ];
}
