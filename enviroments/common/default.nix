{ pkgs, ... }:
{
  imports = [
      ../../users
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget
  ];
}