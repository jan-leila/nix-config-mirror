{ lib, config, pkgs, ... }:
{
  sops.secrets."passwords/ester" = {
    neededForUsers = true;
    # sopsFile = ../secrets.yaml;
  };

  # Define user accounts
  users.users.ester = {
    isNormalUser = true;
    uid = 1001;
    description = "Ester";
    extraGroups = [ "networkmanager" ];

    hashedPasswordFile = config.sops.secrets."passwords/ester".path;

    packages = with pkgs; [
      firefox
      bitwarden
      discord
    ];
  };
}