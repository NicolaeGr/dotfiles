{ lib, fetchzip, ... }:
# https://github.com/naipefoundry/gabarito/releases/tag/v1.000

let
  version = "1.000";
in
fetchzip {
  inherit version;

  url = "https://github.com/naipefoundry/gabarito/releases/download/v${version}/gabarito-fonts.zip";
  sha256 = "pqpeINEkPi/YkczhH6uVEnyF0EFhRmb2nbuAu7HAL9o=";
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
