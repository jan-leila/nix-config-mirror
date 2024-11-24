{lib, ...}: {
  options.host.hardware = {
    piperMouse = {
      enable = lib.mkEnableOption "host has a piper mouse";
    };
    viaKeyboard = {
      enable = lib.mkEnableOption "host has a via keyboard";
    };
    openRGB = {
      enable = lib.mkEnableOption "host has open rgb hardware";
    };
    graphicsAcceleration = {
      enable = lib.mkEnableOption "host has a gpu for graphical acceleration";
    };
  };
}
