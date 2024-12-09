{...}: {
  home.persistence."/persistent/home/leyla" = {
    directories = [
      "desktop"
      "downloads"
      "documents"
      ".ssh"
      ".nixops"
      ".local/share/keyrings"
      ".local/share/direnv"
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
    ];
    # files = [
    #   ".screenrc"
    # ];
    allowOther = true;
  };
}
