{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  userConfig = osConfig.host.users.leyla;
  hardware = osConfig.host.hardware;
in {
  imports = [
    ./vscode.nix
    ./firefox.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home = {
    packages =
      lib.lists.optionals userConfig.isTerminalUser (
        with pkgs; [
          # command line tools
          yt-dlp
          ffmpeg
          imagemagick
        ]
      )
      ++ (
        lib.lists.optionals userConfig.isDesktopUser (
          with pkgs; [
            # helvetica font
            aileron

            gnomeExtensions.dash-to-dock

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
            tor-browser

            # proprietary platforms
            discord
            obsidian
            # steam
            (lib.mkIf hardware.graphicsAcceleration.enable davinci-resolve)

            anki

            # development tools
            # androidStudioPackages.canary
            jetbrains.idea-community
            dbeaver-bin
            bruno
            qFlipper
            proxmark3

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
