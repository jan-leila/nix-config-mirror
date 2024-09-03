{ lib, config, pkgs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports = [
    ../../overlays/intellij.nix
    ../../overlays/vscodium.nix
  ];

  programs.bash.shellAliases = lib.mkIf cfg.isFullUser ({
    code = "codium";
  });

  programs.steam = lib.mkIf cfg.isFullUser ({
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  });

  programs.noisetorch.enable = cfg.isFullUser;

  programs.adb.enable = cfg.isFullUser;

  users.users.leyla.packages = lib.mkIf (cfg.isFullUser || cfg.isThinUser) (
    lib.mkMerge [
      (
        with pkgs; [
          # comand line tools
          yt-dlp
          ffmpeg
          imagemagick
        ]
      )
      (
        lib.mkIf (!cfg.isThinUser) (
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
            # cura
            kicad-small
            makemkv
            transmission_4-gtk
            onionshare
            easytag
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
            
            # development tools
            vscodium
            androidStudioPackages.canary
            jetbrains.idea-community
            dbeaver-bin
            bruno

            # system tools
            protonvpn-gui
            nextcloud-client
            noisetorch

            # hardware managment tools
            (lib.mkIf cfg.hasPiperMouse piper)
            (lib.mkIf cfg.hasOpenRGBHardware openrgb)
            (lib.mkIf cfg.hasViaKeyboard via)
          ]
        )
      )
    ]
  );
}