{
  config,
  lib,
  ...
}: {
  users.users =
    lib.attrsets.mapAttrs (name: value: {
      openssh.authorizedKeys.keys = value.programs.openssh.authorizedKeys;
    })
    config.home-manager.users;
}
