{pkgs, ...}: {
  imports = [
    ../../enviroments/client

    ../../modules
  ];

  nixpkgs.config.allowUnfree = true;

  host = {
    users = {
      leyla = {
        isDesktopUser = true;
        isTerminalUser = true;
        isPrincipleUser = true;
      };
      ester.isDesktopUser = true;
      eve.isDesktopUser = true;
    };
    hardware = {
      piperMouse.enable = true;
      viaKeyboard.enable = true;
      openRGB.enable = true;
      graphicsAcceleration.enable = true;
    };
  };

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>156</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>DP-4</connector>
                <vendor>DEL</vendor>
                <product>DELL U2719D</product>
                <serial>8RGXNS2</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>59.951</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>2560</x>
            <y>324</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-2</connector>
                <vendor>GSM</vendor>
                <product>LG ULTRAGEAR</product>
                <serial>0x00068c96</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>240.001</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>4480</x>
            <y>0</y>
            <scale>1</scale>
            <transform>
              <rotation>left</rotation>
              <flipped>no</flipped>
            </transform>
            <monitor>
              <monitorspec>
                <connector>HDMI-0</connector>
                <vendor>HWP</vendor>
                <product>HP w2207</product>
                <serial>CND7332S88</serial>
              </monitorspec>
              <mode>
                <width>1600</width>
                <height>1000</height>
                <rate>59.999</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-1</connector>
                <vendor>DEL</vendor>
                <product>DELL U2719D</product>
                <serial>8RGXNS2</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>59.951</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>4480</x>
            <y>226</y>
            <scale>1</scale>
            <transform>
              <rotation>left</rotation>
              <flipped>no</flipped>
            </transform>
            <monitor>
              <monitorspec>
                <connector>HDMI-1</connector>
                <vendor>HWP</vendor>
                <product>HP w2207</product>
                <serial>CND7332S88</serial>
              </monitorspec>
              <mode>
                <width>1680</width>
                <height>1050</height>
                <rate>59.954</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>2560</x>
            <y>226</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>DP-2</connector>
                <vendor>GSM</vendor>
                <product>LG ULTRAGEAR</product>
                <serial>0x00068c96</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>240.001</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
        <configuration>
          <logicalmonitor>
            <x>2560</x>
            <y>228</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-2</connector>
                <vendor>GSM</vendor>
                <product>LG ULTRAGEAR</product>
                <serial>0x00068c96</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1080</height>
                <rate>240.001</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>4480</x>
            <y>69</y>
            <scale>1</scale>
            <transform>
              <rotation>left</rotation>
              <flipped>no</flipped>
            </transform>
            <monitor>
              <monitorspec>
                <connector>HDMI-1</connector>
                <vendor>HWP</vendor>
                <product>HP w2207</product>
                <serial>CND7332S88</serial>
              </monitorspec>
              <mode>
                <width>1680</width>
                <height>1050</height>
                <rate>59.954</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>DP-3</connector>
                <vendor>DEL</vendor>
                <product>DELL U2719D</product>
                <serial>8RGXNS2</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>59.951</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <disabled>
            <monitorspec>
              <connector>None-1</connector>
              <vendor>unknown</vendor>
              <product>unknown</product>
              <serial>unknown</serial>
            </monitorspec>
          </disabled>
        </configuration>
      </monitors>
    ''}"
  ];

  # enabled virtualisation for docker
  # virtualisation.docker.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
