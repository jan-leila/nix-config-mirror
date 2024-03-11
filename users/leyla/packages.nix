{ lib, config, pkgs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports = [
    ../../overlays/intellij.nix
    ../../overlays/vscodium.nix
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  users.users.leyla.packages = lib.mkIf cfg.isNormalUser (
    with pkgs; [
      #foss platforms
      signal-desktop
      bitwarden
      firefox
      ungoogled-chromium
      libreoffice
      inkscape
      freecad
      kicad-small
      cura
      makemkv
      transmission-gtk
      easytag
      rhythmbox

      # proprietary platforms
      discord
      obsidian
      
      # development enviroments
      vscodium
      androidStudioPackages.canary
      jetbrains.idea-community
      dbeaver

      # development tools
      # TODO: move these to flakes
      nodejs
      
      # bridges
      protonvpn-gui
      nextcloud-client
      
      # gaming
      # steam
      # emulators
      # nintendo
      yuzu-mainline # Switch Emulator
      citra-canary # 3DS emulator
      cemu # Wii-U emulator
      dolphin-emu # GameCube and Wii Emulator
      desmume # DS Emulator
      mupen64plus # N64 Emulator
      zsnes # SNES Emulator
      vbam # Game Boy Advanced Emulator
      fceux # NES Emulator
      # play station
      rpcs3 # PS3 Emulator
      #misc
      stella # Atari 2600 Emulator
      mame # mame Emulator
    ]
  );
}