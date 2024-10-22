{pkgs, ...}: {
  imports = [
    ../common
  ];

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
        xterm.enable = false;
      };

      # Get rid of xTerm
      excludePackages = [pkgs.xterm];

      # Configure keymap in X11
      xkb = {
        layout = "us,it,de";
        variant = "";
      };
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
  hardware.flipperzero.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    # helvetica font
    aileron

    cachefilesd

    gnomeExtensions.dash-to-dock
  ];
}
