{
  lib,
  osConfig,
  # buildFirefoxXpiAddon,
  pkgs,
  inputs,
  ...
}: let
  cfg = osConfig.nixos.users.leyla;
in {
  # programs.firefox = {
  #   enable = cfg.isDesktopUser;
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

  #     extentions = with inputs.firefox-addons.packages."x86_64-linux"; [
  #         bitwarden
  #         terms-of-service-didnt-read
  #         multi-account-containers
  #         shinigami-eyes

  #         ublock-origin
  #         sponsorblock
  #         dearrow
  #         df-youtube
  #         return-youtube-dislikes

  #         privacy-badger
  #         decentraleyes
  #         clearurls
  #         localcdn

  #         snowflake

  #         deutsch-de-language-pack
  #         dictionary-german

  #         # (
  #         #   buildFirefoxXpiAddon rec {
  #         #     pname = "italiano-it-language-pack";
  #         #     version = "132.0.20241110.231641";
  #         #     addonId = "langpack-it@firefox.mozilla.org";
  #         #     url = "https://addons.mozilla.org/firefox/downloads/file/4392453/italiano_it_language_pack-${version}.xpi";
  #         #     sha256 = "";
  #         #     meta = with lib;
  #         #     {
  #         #       description = "Firefox Language Pack for Italiano (it) – Italian";
  #         #       license = licenses.mpl20;
  #         #       mozPermissions = [];
  #         #       platforms = platforms.all;
  #         #     };
  #         #   }
  #         # )
  #         # (
  #         #   buildFirefoxXpiAddon rec {
  #         #     pname = "dizionario-italiano";
  #         #     version = "5.1";
  #         #     addonId = "it-IT@dictionaries.addons.mozilla.org";
  #         #     url = "https://addons.mozilla.org/firefox/downloads/file/1163874/dizionario_italiano-${version}.xpi";
  #         #     sha256 = "";
  #         #     meta = with lib;
  #         #     {
  #         #       description = "Add support for Italian to spellchecking";
  #         #       license = licenses.gpl3;
  #         #       mozPermissions = [];
  #         #       platforms = platforms.all;
  #         #     };
  #         #   }
  #         # )
  #     ];

  #     settings = {
  #       # Disable irritating first-run stuff
  #       "browser.disableResetPrompt" = true;
  #       "browser.download.panel.shown" = true;
  #       "browser.feeds.showFirstRunUI" = false;
  #       "browser.messaging-system.whatsNewPanel.enabled" = false;
  #       "browser.rights.3.shown" = true;
  #       "browser.shell.checkDefaultBrowser" = false;
  #       "browser.shell.defaultBrowserCheckCount" = 1;
  #       "browser.startup.homepage_override.mstone" = "ignore";
  #       "browser.uitour.enabled" = false;
  #       "startup.homepage_override_url" = "";
  #       "trailhead.firstrun.didSeeAboutWelcome" = true;
  #       "browser.bookmarks.restore_default_bookmarks" = false;
  #       "browser.bookmarks.addedImportButton" = true;

  #       # Usage Experiance
  #       "browser.startup.homepage" = "about:home";
  #       "browser.download.useDownloadDir" = false;
  #       "browser.uiCustomization.state" = builtins.toJSON {
  #         "currentVersion" = 20;
  #         "newElementCount" = 6;
  #         "dirtyAreaCache" = [
  #           "nav-bar"
  #           "PersonalToolbar"
  #           "toolbar-menubar"
  #           "TabsToolbar"
  #           "unified-extensions-area"
  #           "vertical-tabs"
  #         ];
  #         "placements" = {
  #           "widget-overflow-fixed-list" = [];
  #           "unified-extensions-area"= [
  #             "ublock0_raymondhill_net-browser-action"
  #             "sponsorblocker_ajay_app-browser-action"
  #             "dearrow_ajay_app-browser-action"
  #             "privacy_privacy_com-browser-action"
  #             "addon_simplelogin-browser-action"
  #           ];
  #           "nav-bar" = [
  #             "back-button"
  #             "forward-button"
  #             "stop-reload-button"
  #             "urlbar-container"
  #             "downloads-button"
  #             "unified-extensions-button"
  #             "reset-pbm-toolbar-button"
  #           ];
  #           "toolbar-menubar" = [
  #             "menubar-items"
  #           ];
  #           "TabsToolbar" = [
  #             "firefox-view-button"
  #             "tabbrowser-tabs"
  #             "new-tab-button"
  #             "alltabs-button"
  #           ];
  #           "vertical-tabs" = [];
  #           "PersonalToolbar" = [
  #             "import-button"
  #             "personal-bookmarks"
  #           ];
  #         };
  #         "seen" = [
  #           "save-to-pocket-button"
  #           "developer-button"
  #           "privacy_privacy_com-browser-action"
  #           "sponsorblocker_ajay_app-browser-action"
  #           "ublock0_raymondhill_net-browser-action"
  #           "addon_simplelogin-browser-action"
  #           "dearrow_ajay_app-browser-action"
  #         ];
  #       };
  #       "browser.newtabpage.activity-stream.feeds.topsites" = false;
  #       "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
  #       "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
  #       "browser.newtabpage.blocked" = lib.genAttrs [
  #         # Facebook
  #         "4gPpjkxgZzXPVtuEoAL9Ig=="
  #         # Reddit
  #         "gLv0ja2RYVgxKdp0I5qwvA=="
  #         # Amazon
  #         "K00ILysCaEq8+bEqV/3nuw=="
  #         # Twitter
  #         "T9nJot5PurhJSy8n038xGA=="
  #       ] (_: 1);
  #       "signon.rememberSignons" = false;
  #       "identity.fxaccounts.enabled" = false;

  #       # Security
  #       "privacy.trackingprotection.enabled" = true;
  #       "dom.security.https_only_mode" = true;

  #       # Disable telemetry
  #       "app.shield.optoutstudies.enabled" = false;
  #       "browser.discovery.enabled" = false;
  #       "browser.newtabpage.activity-stream.feeds.telemetry" = false;
  #       "browser.newtabpage.activity-stream.telemetry" = false;
  #       "browser.ping-centre.telemetry" = false;
  #       "datareporting.healthreport.service.enabled" = false;
  #       "datareporting.healthreport.uploadEnabled" = false;
  #       "datareporting.policy.dataSubmissionEnabled" = false;
  #       "datareporting.sessions.current.clean" = true;
  #       "devtools.onboarding.telemetry.logged" = false;
  #       "toolkit.telemetry.archive.enabled" = false;
  #       "toolkit.telemetry.bhrPing.enabled" = false;
  #       "toolkit.telemetry.enabled" = false;
  #       "toolkit.telemetry.firstShutdownPing.enabled" = false;
  #       "toolkit.telemetry.hybridContent.enabled" = false;
  #       "toolkit.telemetry.newProfilePing.enabled" = false;
  #       "toolkit.telemetry.prompted" = 2;
  #       "toolkit.telemetry.rejected" = true;
  #       "toolkit.telemetry.reportingpolicy.firstRun" = false;
  #       "toolkit.telemetry.server" = "";
  #       "toolkit.telemetry.shutdownPingSender.enabled" = false;
  #       "toolkit.telemetry.unified" = false;
  #       "toolkit.telemetry.unifiedIsOptIn" = false;
  #       "toolkit.telemetry.updatePing.enabled" = false;
  #     };

  #     bookmarks = [
  #       {
  #         name = "Media";
  #         url = "https://jellyfin.jan-leila.com/";
  #         # url = "https://media.jan-leila.com/";
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
  #         url = "https://mspsocial.net";
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
  # };
}
