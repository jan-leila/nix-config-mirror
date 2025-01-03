{...}: {
  imports = [
    ./network_storage
    ./reverse_proxy.nix
    ./postgres.nix
    ./jellyfin.nix
    ./forgejo.nix
    ./searx.nix
    ./home-assistant.nix
  ];
}
