{...}: {
  imports = [
    ./fail2ban.nix
    ./network_storage
    ./reverse_proxy.nix
    ./postgres.nix
    ./podman.nix
    ./jellyfin.nix
    ./forgejo.nix
    ./searx.nix
    ./home-assistant.nix
    ./pihole.nix
    ./nextcloud.nix
  ];
}
