{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  cfg = osConfig.host.users.leyla;
  hardware = osConfig.host.hardware;
in {
  imports = [
    ./vscode.nix
    ./firefox.nix
  ];

  home = {
    packages =
      lib.lists.optionals cfg.isTerminalUser (
        with pkgs; [
          # comand line tools
          yt-dlp
          ffmpeg
          imagemagick
        ]
      )
      ++ (
        lib.lists.optionals cfg.isDesktopUser (
          with pkgs; [
            #foss platforms
            signal-desktop
            bitwarden
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
            (lib.mkIf hardware.graphicsAcceleration.enable obs-studio)
            # wireshark
            # rpi-imager
            # fritzing
            mfoc

            # proprietary platforms
            discord
            obsidian
            steam
            (lib.mkIf hardware.graphicsAcceleration.enable davinci-resolve)

            anki-bin

            # development tools
            androidStudioPackages.canary
            jetbrains.idea-community
            dbeaver-bin
            bruno
            qFlipper
            proxmark3
            godot_4-mono

            # system tools
            protonvpn-gui
            openvpn
            nextcloud-client
            noisetorch

            # hardware managment tools
            (lib.mkIf hardware.piperMouse.enable piper)
            (lib.mkIf hardware.openRGB.enable openrgb)
            (lib.mkIf hardware.viaKeyboard.enable via)
          ]
        )
      );
  };
}
