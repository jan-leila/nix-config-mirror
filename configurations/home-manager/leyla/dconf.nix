{
  lib,
  pkgs,
  ...
}: {
  config = {
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

        "org/gnome/shell" = {
          favorite-apps = ["org.gnome.Nautilus.desktop" "firefox.desktop" "codium.desktop" "steam.desktop" "org.gnome.Console.desktop"];
          # app-picker-layout =
          #   builtins.map (
          #     applications:
          #       lib.hm.gvariant (builtins.listToAttrs (lib.lists.imap0 (i: v: lib.attrsets.nameValuePair v (lib.hm.gvariant.mkVariant "{'position': <${i}>}")) applications))
          #   ) [
          #     [
          #       "org.gnome.Nautilus.desktop"
          #       "bitwarden.desktop"
          #       "firefox.desktop"
          #       "torbrowser.desktop"
          #       "chromium-browser.desktop"
          #       "codium.desktop"
          #       "idea-community.desktop"
          #       "org.gnome.TextEditor.desktop"
          #       "dbeaver.desktop"
          #       "bruno.desktop"
          #       "anki.desktop"
          #       "obsidian.desktop"
          #       "signal-desktop.desktop"
          #       "discord.desktop"
          #       "gimp.desktop"
          #       "org.inkscape.Inkscape.desktop"
          #       "org.kde.krita.desktop"
          #       "davinci-resolve.desktop"
          #       "com.obsproject.Studio.desktop"
          #       "org.freecad.FreeCAD.desktop"
          #       "makemkv.desktop"
          #       "easytag.desktop"
          #       "transmission-gtk.desktop"
          #     ]
          #     [
          #       "SteamVR.desktop"
          #       "Beat Saber.desktop"
          #       "Noun Town.desktop"
          #       "WEBFISHING.desktop"
          #       "Factorio.desktop"
          #     ]
          #     [
          #       "org.gnome.Settings.desktop"
          #       "org.gnome.SystemMonitor.desktop"
          #       "org.gnome.Snapshot.desktop"
          #       "org.gnome.Usage.desktop"
          #       "org.gnome.DiskUtility.desktop"
          #       "org.gnome.Evince.desktop"
          #       "org.gnome.fonts.desktop"
          #       "noisetorch.desktop"
          #       "nvidia-settings.desktop"
          #       "OpnRGB.desktop"
          #       "org.freedesktop.Piper.desktop"
          #       "via-nativia.desktop"
          #       "protonvpn-app.desktop"
          #       "simple-scan.desktop"
          #     ]
          #   ];
        };
      };
    };
  };
}
