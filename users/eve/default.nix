{ lib, config, pkgs, ... }:
{
  sops.secrets."passwords/eve" = {
    neededForUsers = true;
    # sopsFile = ../secrets.yaml;
  };

  # Define user accounts
  users.users.eve = {
    isNormalUser = true;
    uid = 1002;
    description = "Eve";
    extraGroups = [ "networkmanager" ];

    hashedPasswordFile = config.sops.secrets."passwords/eve".path;

    packages = with pkgs; [
      firefox
      bitwarden
      discord
      makemkv
      signal-desktop
    ];
  };
}