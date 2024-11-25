{
  lib,
  config,
  ...
}: {
  options = {
    i18n = {
      defaultLocale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        example = "nl_NL.UTF-8";
        description = ''
          The default locale.  It determines the language for program
          messages, the format for dates and times, sort order, and so on.
          It also determines the character set, such as UTF-8.
        '';
      };

      extraLocaleSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        example = {
          LC_MESSAGES = "en_US.UTF-8";
          LC_TIME = "de_DE.UTF-8";
        };
        description = ''
          A set of additional system-wide locale settings other than
          `LANG` which can be configured with
          {option}`i18n.defaultLocale`.
        '';
      };
    };
  };

  config = {
    home.sessionVariables =
      {
        LANG = config.i18n.defaultLocale;
      }
      // config.i18n.extraLocaleSettings;
  };
}
