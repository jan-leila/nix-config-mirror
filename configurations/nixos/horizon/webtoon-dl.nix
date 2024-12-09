{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
buildGoModule rec {
  pname = "webtoon-dl";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "robinovitch61";
    repo = "webtoon-dl";
    rev = "v${version}";
    hash = "sha256-geVb3LFPZxPQYARZnaqOr5sgaN6mqkEX5ZiLvg8mF5k=";
  };

  vendorHash = "sha256-NTqUygJ6b6kTnLUnJqxCo/URzaRouPLACEPi2Ob1s9w=";
}
