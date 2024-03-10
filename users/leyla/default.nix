{ lib, config, pkgs, ... }:
{
  sops.secrets."passwords/leyla" = {
    neededForUsers = true;
    # sopsFile = ../secrets.yaml;
  };

  # Define user accounts
  users.users.leyla = {
    isNormalUser = true;
    uid = 1000;
    description = "Leyla";
    extraGroups = [ "networkmanager" "wheel" ];

    hashedPasswordFile = config.sops.secrets."passwords/leyla".path;
    
    packages = with pkgs; [
      iputils
      dnsutils
      git
      firefox
      signal-desktop
      obsidian
      bitwarden
      vscodium
      nextcloud-client
      inkscape
      steam
      discord
      rhythmbox
      makemkv
      protonvpn-gui
      transmission-gtk
      freecad
      mupen64plus
      dbeaver
      easytag
      cura
      kicad-small
#        jdk
#        android-tools
#        android-studio
      androidStudioPackages.canary
      jetbrains.idea-community
      ungoogled-chromium
      nodejs
      exiftool
      libreoffice
      # N64 Emulator
      mupen64plus
      # GameCube Emulator and Wii Emulator
      dolphin-emu
      # Switch Emulator
      yuzu-mainline
      # Atari 2600 Emulator
      stella
      # mame Emulator
      mame
      # Game Boy Advanced Emulator
      vbam
      # NES Emulator
      fceux
      # SNES Emulator
      zsnes
      # DS Emulator
      desmume
    ];
  };
}