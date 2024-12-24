{lib, ...}: {
  options.programs = {
    openssh.authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
}
