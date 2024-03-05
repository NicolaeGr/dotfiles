{ lib, fetchzip, fetchFromGitHub, makeFont }:
# make a package for the gabarito font. will fetch from github.
# https://github.com/naipefoundry/gabarito/releases/tag/v1.000
# file name is  gabarito-fonts.zip 

let
  version = "1.000";
in
fetchzip {
  inherit version;
  
  url = "https://github.com/naipefoundry/gabarito/releases/download/v${version}/gabarito-fonts.zip";
  sha256 = "09wm6rxz7c1y8qbcn74kpn5h71b1n9hmp9x3fzi3jl3h1iivr0l4";
  name = "gabarito-fonts";

  postFetch = ''
    mkdir -p $out/share/fonts
    cp -r $out/fonts/* $out/share/fonts
  '';

  meta = with lib; {
    description = "Gabarito is a typeface designed by Naipe Foundry. It is a display typeface with a strong personality, inspired by the aesthetics of wood type and the style of the 19th century.";
    license = licenses.ofl;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
