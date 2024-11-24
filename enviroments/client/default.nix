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

  environment.systemPackages = with pkgs; [
    cachefilesd
  ];
}
