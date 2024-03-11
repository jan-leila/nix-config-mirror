{ lib, config, pkgs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports = [
    ../../overlays/intellij.nix
    ../../overlays/vscodium.nix
  ];

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
      steam
      # emulators
      yuzu-mainline # Switch Emulator
      dolphin-emu # GameCube and Wii Emulator
      desmume # DS Emulator
      mupen64plus # N64 Emulator
      zsnes # SNES Emulator
      vbam # Game Boy Advanced Emulator
      fceux # NES Emulator
      stella # Atari 2600 Emulator
      mame # mame Emulator
      
      
    ]
  );
}