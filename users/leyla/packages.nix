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

  programs.noisetorch.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
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
      gimp
      krita
      freecad
      cura
      kicad-small
      makemkv
      transmission-gtk
      onionshare
      # easytag
      # rhythmbox
      (lib.mkIf cfg.hasGPU obs-studio)
      # wireshark
      # rpi-imager
      # fritzing

      # proprietary platforms
      discord
      obsidian
      steam
      (lib.mkIf cfg.hasGPU davinci-resolve)
      
      # development enviroments
      vscodium
      androidStudioPackages.canary
      jetbrains.idea-community
      dbeaver

      # development tools
      # TODO: move these to flakes
      nodejs
      
      # system tools
      protonvpn-gui
      nextcloud-client
      noisetorch

      # hardware managment tools
      (lib.mkIf cfg.hasPiperMouse piper)
      (lib.mkIf cfg.hasOpenRGBHardware openrgb)
      (lib.mkIf cfg.hasViaKeyboard via)

      # gaming
      # emulators
      # nintendo
      # TODO: replace this with self hosted flake
      # (lib.mkIf cfg.hasGPU yuzu-mainline) # Switch Emulator
      # TODO: replace this with self hosted flake
      # citra-canary # 3DS emulator
      (lib.mkIf cfg.hasGPU cemu) # Wii-U emulator
      dolphin-emu # GameCube and Wii Emulator
      desmume # DS Emulator
      mupen64plus # N64 Emulator
      zsnes # SNES Emulator
      vbam # Game Boy Advanced Emulator
      fceux # NES Emulator
      # play station
      rpcs3 # PS3 Emulator
      pcsx2 # PS2 Emulator
      pcsxr # PS1 Emulator
      # TODO: more play station emulators here when they come out
      #misc
      stella # Atari 2600 Emulator
      mame # mame Emulator
    ]
  );
}