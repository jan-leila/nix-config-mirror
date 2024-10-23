{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = osConfig.nixos.users.leyla;
in {
  imports = [
    ./vscode.nix
    ./firefox.nix
  ];

  home = {
    packages = lib.mkIf (cfg.isDesktopUser || cfg.isTerminalUser) (
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
          lib.mkIf (!cfg.isTerminalUser) (
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
              # kicad-small
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

              anki-bin

              # development tools
              androidStudioPackages.canary
              jetbrains.idea-community
              dbeaver-bin
              bruno
              qFlipper

              # system tools
              protonvpn-gui
              openvpn
              nextcloud-client
              noisetorch

              # hardware managment tools
              (lib.mkIf osConfig.hardware.piperMouse.enable piper)
              (lib.mkIf osConfig.hardware.openRGB.enable openrgb)
              (lib.mkIf osConfig.hardware.viaKeyboard.enable via)
            ]
          )
        )
      ]
    );
  };
}
