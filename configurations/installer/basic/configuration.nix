{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AaAeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee username@host"
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  networking.hostName = "installer";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
