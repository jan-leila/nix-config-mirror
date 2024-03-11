{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      # idea is too out of date for android gradle things
      jetbrains = {
        jdk = super.jdk17;
        idea-community = super.jetbrains.idea-community.overrideAttrs (oldAttrs: rec {
          version = "2023.3.3";
          name = "idea-community-${version}";
          src = super.fetchurl {
            sha256 = "sha256-3BI97Tx+3onnzT1NXkb62pa4dj9kjNDNvFt9biYgP9I=";
            url = "https://download.jetbrains.com/idea/ideaIC-${version}.tar.gz";
          };
        });
      };
    })
  ];
}