{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common
  ];

  # Enable sound with pipewire.
  hardware.flipperzero.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    # helvetica font
    aileron

    cachefilesd

    gnomeExtensions.dash-to-dock
  ];
}
