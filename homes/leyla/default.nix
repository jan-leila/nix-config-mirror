{
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./packages.nix
  ];

  config = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home = {
      username = "leyla";
      # homeDirectory = osConfig.users.users.leyla.home;

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      stateVersion = "23.11"; # Please read the comment before changing.

      # Home Manager is pretty good at managing dotfiles. The primary way to manage
      # plain files is through 'home.file'.
      file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
        ".config/user-dirs.dirs" = {
          force = true;
          text = ''
            # This file is written by xdg-user-dirs-update
            # If you want to change or add directories, just edit the line you're
            # interested in. All local changes will be retained on the next run.
            # Format is XDG_xxx_DIR="$HOME/yyy", where yyy is a shell-escaped
            # homedir-relative path, or XDG_xxx_DIR="/yyy", where /yyy is an
            # absolute path. No other format is supported.
            #
            XDG_DESKTOP_DIR="$HOME/desktop"
            XDG_DOWNLOAD_DIR="$HOME/downloads"
            XDG_DOCUMENTS_DIR="$HOME/documents"
            XDG_TEMPLATES_DIR="$HOME/documents/templates"
            XDG_MUSIC_DIR="$HOME/documents/music"
            XDG_PICTURES_DIR="$HOME/documents/photos"
            XDG_VIDEOS_DIR="$HOME/documents/videos"
            XDG_PUBLICSHARE_DIR="$HOME/documents/public"
          '';
        };
      };

      # Home Manager can also manage your environment variables through
      # 'home.sessionVariables'. If you don't want to manage your shell through Home
      # Manager then you have to manually source 'hm-session-vars.sh' located at
      # either
      #
      #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
      #
      # or
      #
      #  /etc/profiles/per-user/leyla/etc/profile.d/hm-session-vars.sh
      #
      sessionVariables = {
        # EDITOR = "emacs";
      };
    };

    programs = {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;

      # set up git defaults
      git = {
        enable = true;
        userName = "Leyla Becker";
        userEmail = "git@jan-leila.com";
        extraConfig.init.defaultBranch = "main";
      };

      # add direnv to auto load flakes for development
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
        config = {
          global.hide_env_diff = true;
          whitelist.exact = ["/home/leyla/documents/code/nix-config"];
        };
      };
      bash.enable = true;

      # firefox = {
      #   enable = true;
      #   profiles.leyla = {

      #     settings = {
      #         "browser.search.defaultenginename" = "Searx";
      #         "browser.search.order.1" = "Searx";
      #     };

      #     search = {
      #       force = true;
      #       default = "Searx";
      #       engines = {
      #         "Nix Packages" = {
      #           urls = [{
      #             template = "https://search.nixos.org/packages";
      #             params = [
      #               { name = "type"; value = "packages"; }
      #               { name = "query"; value = "{searchTerms}"; }
      #             ];
      #           }];
      #           icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      #           definedAliases = [ "@np" ];
      #         };
      #         "NixOS Wiki" = {
      #           urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
      #           iconUpdateURL = "https://nixos.wiki/favicon.png";
      #           updateInterval = 24 * 60 * 60 * 1000; # every day
      #           definedAliases = [ "@nw" ];
      #         };
      #         "Searx" = {
      #           urls = [{ template = "https://search.jan-leila.com/?q={searchTerms}"; }];
      #           iconUpdateURL = "https://nixos.wiki/favicon.png";
      #           updateInterval = 24 * 60 * 60 * 1000; # every day
      #           definedAliases = [ "@searx" ];
      #         };
      #       };
      #     };

      #     extentions = with pkgs.nur.repos.rycee.firefox-addons; [
      #         ublock-origin
      #         bitwarden

      #     ];

      #     bookmarks = [
      #       {
      #         name = "Media";
      #         url = "https://jellyfin.jan-leila.com/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Drive";
      #         url = "https://drive.jan-leila.com/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Git";
      #         url = "https://git.jan-leila.com/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Home Automation";
      #         url = "https://home-assistant.jan-leila.com/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Mail";
      #         url = "https://mail.protonmail.com";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Open Street Map";
      #         url = "https://www.openstreetmap.org/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Password Manager";
      #         url = "https://vault.bitwarden.com/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Mastodon";
      #         url = "https://tech.lgbt";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Linked In";
      #         url = "https://www.linkedin.com/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "Job Search";
      #         url = "https://www.jobsinnetwork.com/?state=cleaned_history&language%5B%5D=en&query=react&locations.countryCode%5B%5D=IT&locations.countryCode%5B%5D=DE&locations.countryCode%5B%5D=NL&experience%5B%5D=medior&experience%5B%5D=junior&page=1";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       {
      #         name = "React Docs";
      #         url = "https://react.dev/";
      #         keyword = "";
      #         tags = [""];
      #       }
      #       # Template
      #       # {
      #       #   name = "";
      #       #   url = "";
      #       #   keyword = "";
      #       #   tags = [""];
      #       # }
      #     ];
      #   };
      # }
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";

        "org/gnome/shell" = {
          disable-user-extensions = false; # enables user extensions
          enabled-extensions = [
            # Put UUIDs of extensions that you want to enable here.
            # If the extension you want to enable is packaged in nixpkgs,
            # you can easily get its UUID by accessing its extensionUuid
            # field (look at the following example).
            pkgs.gnomeExtensions.dash-to-dock.extensionUuid

            # Alternatively, you can manually pass UUID as a string.
            # "dash-to-dock@micxgx.gmail.com"
          ];
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          "dock-position" = "LEFT";
          "intellihide-mode" = "ALL_WINDOWS";
          "show-trash" = false;
          "require-pressure-to-show" = false;
          "show-mounts" = false;
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "kgx";
          name = "Open Terminal";
        };
      };
    };
  };
}
