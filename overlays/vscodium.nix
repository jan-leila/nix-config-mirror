_: {
  # nixpkgs.overlays = [
  #   (self: super: {
  #     # ui is broken on 1.84
  #     vscodium = super.vscodium.overrideAttrs (oldAttrs: rec {
  #       version = "1.85.2.24019";
  #       src = super.fetchurl {
  #         sha256 = "sha256-OBGFXOSN+Oq9uj/5O6tF0Kp7rxTY1AzNbhLK8G+EqVk=";
  #         url = "https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-linux-x64-${version}.tar.gz";
  #       };
  #     });
  #   })
  # ];
}
