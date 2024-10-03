{
  lib,
  config,
  osConfig,
  pkgs,
  inputs,
  ...
}: {
  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  programs = {
    bash.shellAliases = lib.mkIf config.isFullUser {
      code = "codium";
    };

    vscode = let
      extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
      open-vsx = extensions.open-vsx;
      vscode-marketplace = extensions.vscode-marketplace;
    in {
      enable = true;

      package = pkgs.vscodium;

      mutableExtensionsDir = false;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      userSettings = {
        "workbench.colorTheme" = "Atom One Dark";
        "cSpell.userWords" = [
          "webdav"
        ];
      };

      extensions = with extensions.open-vsx;
        [
          # vs code feel extensions
          ms-vscode.atom-keybindings
          akamud.vscode-theme-onedark
          streetsidesoftware.code-spell-checker
          streetsidesoftware.code-spell-checker-german
          streetsidesoftware.code-spell-checker-italian
          jeanp413.open-remote-ssh

          # nix extensions
          pinage404.nix-extension-pack
          jnoortheen.nix-ide

          # html extensions
          formulahendry.auto-rename-tag
          ms-vscode.live-server

          # js extensions
          dsznajder.es7-react-js-snippets
          dbaeumer.vscode-eslint
          standard.vscode-standard
          firsttris.vscode-jest-runner
          stylelint.vscode-stylelint
          tauri-apps.tauri-vscode

          # misc extensions
          bungcip.better-toml

          # the number at the start of the name here doesnt resolve nicely so we have to refernce it as a part of open-vsx directly instead of though with
          open-vsx."10nates".ollama-autocoder
        ]
        ++ (with extensions.vscode-marketplace; [
          # js extensions
          karyfoundation.nearley
        ]);
    };
  };

  home = {
    packages = lib.mkIf (config.isFullUser || config.isThinUser) (
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
          lib.mkIf (!config.isThinUser) (
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
