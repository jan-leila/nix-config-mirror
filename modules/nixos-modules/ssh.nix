{...}: {
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
