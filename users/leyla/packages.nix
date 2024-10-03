{
  lib,
  config,
  osConfig,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./vscode.nix
    ./firefox.nix
  ];

  home = {
    packages = lib.mkIf (config.isDesktopUser || config.isTerminalUser) (
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
          lib.mkIf (!config.isTerminalUser) (
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
              (lib.mkIf config.hasGPU obs-studio)
              # wireshark
              # rpi-imager
              # fritzing

              # proprietary platforms
              discord
              obsidian
              steam
              (lib.mkIf config.hasGPU davinci-resolve)

              # development tools
              androidStudioPackages.canary
              jetbrains.idea-community
              dbeaver-bin
              bruno

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
