{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  programs = {
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
}
