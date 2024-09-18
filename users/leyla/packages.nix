{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.users.leyla;
in
{
  imports = [
    ../../overlays/intellij.nix
    ../../overlays/vscodium.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  programs = {
    bash.shellAliases = lib.mkIf cfg.isFullUser {
      code = "codium";
    };

    steam = lib.mkIf cfg.isFullUser {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    noisetorch.enable = cfg.isFullUser;

    adb.enable = cfg.isFullUser;
  };

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
            (vscode-with-extensions.override {
              vscode = vscodium;
              vscodeExtensions = with open-vsx; [
                jeanp413.open-remote-ssh
              ] ++ (with vscode-marketplace; [
                # vs code feel extensions
                ms-vscode.atom-keybindings
                akamud.vscode-theme-onedark
                streetsidesoftware.code-spell-checker
                streetsidesoftware.code-spell-checker-german
                streetsidesoftware.code-spell-checker-italian

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
                karyfoundation.nearley

                # misc extensions        
                bungcip.better-toml
              ]);
            })
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
            (lib.mkIf cfg.hasPiperMouse piper)
            (lib.mkIf cfg.hasOpenRGBHardware openrgb)
            (lib.mkIf cfg.hasViaKeyboard via)
          ]
        )
      )
    ]
  );
}