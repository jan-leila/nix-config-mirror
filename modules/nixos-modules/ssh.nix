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
        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };
    })
  ];
}
