{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  nix-development-enabled = osConfig.host.nix-development.enable;
in {
  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
  };

  programs = {
    bash.shellAliases = {
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

      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        userSettings = lib.mkMerge [
          {
            "workbench.colorTheme" = "Atom One Dark";
            "cSpell.userWords" = [
              "webdav"
            ];
          }
          (lib.mkIf nix-development-enabled {
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nil";
            "[nix]" = {
              "editor.defaultFormatter" = "kamadorueda.alejandra";
              "editor.formatOnPaste" = true;
              "editor.formatOnSave" = true;
              "editor.formatOnType" = true;
            };
            "alejandra.program" = "alejandra";
            "nixpkgs" = {
              "expr" = "import <nixpkgs> {}";
            };
          })
          (lib.mkIf osConfig.services.ollama.enable {
            "twinny.fileContextEnabled" = true;
            "twinny.enableLogging" = false;
            "twinny.completionCacheEnabled" = true;

            # builtins.elemAt osConfig.services.ollama.loadModels 0;
          })
        ];

        extensions = (
          with open-vsx;
            [
              # vs code feel extensions
              ms-vscode.atom-keybindings
              akamud.vscode-theme-onedark
              streetsidesoftware.code-spell-checker
              streetsidesoftware.code-spell-checker-german
              streetsidesoftware.code-spell-checker-italian
              jeanp413.open-remote-ssh

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

              # go extensions
              golang.go

              # astro blog extensions
              astro-build.astro-vscode
              unifiedjs.vscode-mdx

              # misc extensions
              bungcip.better-toml
            ]
            ++ (
              lib.lists.optionals osConfig.services.ollama.enable [
                rjmacarthy.twinny
              ]
            )
            ++ (lib.lists.optionals nix-development-enabled [
              # nix extensions
              pinage404.nix-extension-pack
              jnoortheen.nix-ide
              kamadorueda.alejandra
            ])
            ++ (
              with vscode-marketplace; [
                # js extensions
                karyfoundation.nearley
              ]
            )
        );
      };
    };
  };
}
