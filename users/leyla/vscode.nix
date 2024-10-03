{
  lib,
  osConfig,
  pkgs,
  inputs,
  ...
}: let
  cfg = osConfig.nixos.users.leyla;
in {
  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  programs = {
    bash.shellAliases = lib.mkIf cfg.isDesktopUser {
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

      extensions = (
        with extensions.open-vsx;
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

            open-vsx."10nates".ollama-autocoder
          ]
          ++ (
            with extensions.vscode-marketplace; [
              # js extensions
              karyfoundation.nearley
            ]
          )
      );
    };
  };
}
