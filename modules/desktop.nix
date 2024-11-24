{
  lib,
  pkgs,
  config,
  ...
}: {
  options.host.desktop.enable = lib.mkEnableOption "should desktop configuration be enabled";

  config = lib.mkMerge [
    {
      host.desktop.enable = lib.mkDefault true;
    }
    (lib.mkIf config.host.desktop.enable {
      services = {
        # Enable CUPS to print documents.
        printing.enable = true;

        xserver = {
          # Enable the X11 windowing system.
          enable = true;

          # Enable the GNOME Desktop Environment.
          displayManager.gdm.enable = true;
          desktopManager = {
            gnome.enable = true;
          };

          # Get rid of xTerm
          desktopManager.xterm.enable = false;
          excludePackages = [pkgs.xterm];
        };

        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;

          # If you want to use JACK applications, uncomment this
          #jack.enable = true;

          # use the example session manager (no others are packaged yet so this is enabled by default,
          # no need to redefine it in your config for now)
          #media-session.enable = true;
        };
      };

      # Enable sound with pipewire.
      hardware.pulseaudio.enable = false;

      # enable RealtimeKit for pulse audio
      security.rtkit.enable = true;
    })
  ];
}
