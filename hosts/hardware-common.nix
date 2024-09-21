{lib, ...}: {
  options = {
    hardware = {
      piperMouse = {
        enable = lib.mkEnableOption "host has a piper mouse";
      };
      viaKeyboard = {
        enable = lib.mkEnableOption "host has a via keyboard";
      };
      openRGB = {
        enable = lib.mkEnableOption "host has open rgb hardware";
      };
    };
  };
}
