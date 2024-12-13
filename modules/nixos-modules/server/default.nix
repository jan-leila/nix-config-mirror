{...}: {
  imports = [
    ./network_storage
    ./reverse_proxy.nix
    ./jellyfin.nix
  ];
}
