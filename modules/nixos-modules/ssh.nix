{
  lib,
  config,
  ...
}: {
  config = lib.mkMerge [
    {
      services = {
        openssh = {
          enable = true;
          ports = [22];
          settings = {
            PasswordAuthentication = false;
            UseDns = true;
            X11Forwarding = false;
          };
        };
      };
    }
    (lib.mkIf config.host.impermanence.enable {
      environment.persistence."/persist/system/root" = {
        files = lib.lists.flatten (
          builtins.map (hostKey: [hostKey.path "${hostKey.path}.pub"]) config.services.openssh.hostKeys
        );
      };
    })
  ];
}
