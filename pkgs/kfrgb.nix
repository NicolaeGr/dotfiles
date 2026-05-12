{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "kfrgb";
  version = "2026-03-31";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/KeyofBlueS/kfrgb/master/kfrgb.sh";
    sha256 = "sha256-4ijHMXYhqnXs0bxiSC/yehDkEcl8fgPou9orQ6H7F4s=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 $src $out/bin/kfrgb
  '';

  meta = with lib; {
    description = "kfrgb - A script to control kfrgb devices";
    homepage = "https://github.com/KeyofBlueS/kfrgb";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
