{config, ...}: {
  home.persistence."/persistent/home/${config.home.username}" = {
    directories = [
      ".ssh"
      "desktop"
      "downloads"
      "documents"
    ];
  };
}
