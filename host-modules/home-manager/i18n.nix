{
  lib,
  config,
  ...
}: let
  home-users = lib.attrsets.mapAttrsToList (_: user: user) config.home-manager.users;
in {
  config = {
    i18n.supportedLocales =
      lib.unique
      (builtins.map (l: (lib.replaceStrings ["utf8" "utf-8" "UTF8"] ["UTF-8" "UTF-8" "UTF-8"] l) + "/UTF-8") (
        [
          "C.UTF-8"
          "en_US.UTF-8"
          config.i18n.defaultLocale
        ]
        ++ (lib.attrValues (lib.filterAttrs (n: v: n != "LANGUAGE") config.i18n.extraLocaleSettings))
        ++ (
          map (user-config: user-config.i18n.defaultLocale) home-users
        )
        ++ (lib.lists.flatten (
          map (user-config: lib.attrValues (lib.filterAttrs (n: v: n != "LANGUAGE") user-config.i18n.extraLocaleSettings)) home-users
        ))
      ));
  };
}
