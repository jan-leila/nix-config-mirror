{lib, ...}: {
  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/system/root@blank
    zfs rollback -r rpool/local/home/leyla@blank
  '';

  # systemd.services = {
  #   # https://github.com/openzfs/zfs/issues/10891
  #   systemd-udev-settle.enable = false;
  #   # Snapshots are not accessible on boot for some reason this should fix it
  #   # https://github.com/NixOS/nixpkgs/issues/257505
  #   zfs-mount = {
  #     serviceConfig = {
  #       ExecStart = ["zfs mount -a -o remount"];
  #       # ExecStart = [
  #       #   "${lib.getExe' pkgs.util-linux "mount"} -t zfs rpool/local -o remount"
  #       #   "${lib.getExe' pkgs.util-linux "mount"} -t zfs rpool/persistent -o remount"
  #       # ];
  #     };
  #   };
  # };

  # boot.initrd.systemd.services.rollback = {
  #   description = "Rollback filesystem to a pristine state on boot";
  #   wantedBy = [
  #     "initrd.target"
  #   ];
  #   after = [
  #     "zfs-import-rpool.service"
  #   ];
  #   before = [
  #     "sysroot.mount"
  #   ];
  #   requiredBy = [
  #     "sysroot.mount"
  #   ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = ''
  #       zfs rollback -r rpool/local/system/root@blank
  #       zfs rollback -r rpool/local/home@blank
  #     '';
  #   };
  # };

  fileSystems."/".neededForBoot = true;
  fileSystems."/home/leyla".neededForBoot = true;
  fileSystems."/persist/system/root".neededForBoot = true;
  fileSystems."/persist/home/leyla".neededForBoot = true;
  fileSystems.${import ../../../const/sops_age_key_directory.nix}.neededForBoot = true;

  environment.persistence."/persist/system/root" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/run/secrets"

      "/etc/ssh"

      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"

      # config.apps.pihole.directory.root

      # config.apps.jellyfin.mediaDirectory
      # config.services.jellyfin.configDir
      # config.services.jellyfin.cacheDir
      # config.services.jellyfin.dataDir

      # "/var/hass" # config.users.users.hass.home
      # "/var/postgresql" # config.users.users.postgresql.home
      # "/var/forgejo" # config.users.users.forgejo.home
      # "/var/nextcloud" # config.users.users.nextcloud.home
      # "/var/headscale" # config.users.users.headscale.home
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  security.sudo.extraConfig = "Defaults lecture=never";
}
