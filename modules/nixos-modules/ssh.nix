{
  lib,
  config,
  ...
}: {
  users.users.leyla.openssh.authorizedKeys.keys = lib.mkIf config.host.users.leyla.isTerminalUser [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHeItmt8TRW43uNcOC+eIurYC7Eunc0V3LGocQqLaYj leyla@horizon"
  ];

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
