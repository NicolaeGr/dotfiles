{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  dotnetCorePackages,
  icu,
  openssl,
  sqlite,
  zlib,
  krb5,
  libunwind,
  lttng-ust_2_12,
  alsa-lib,
  ffmpeg,
}:
let
  pname = "lidarr-nightly";
  version = "nightly-3.1.6.5078";

  src = fetchurl {
    name = "${pname}-${version}.tar.gz";
    url = "https://lidarr.servarr.com/v1/update/nightly/updatefile?os=linux&arch=x64&runtime=netcore";
    hash = "sha256-HYFPI3bKbFxP6R/M2uOksR+xA06zRyC+Sd9wi8+MK4E=";
  };

  rawBinaries = stdenv.mkDerivation {
    pname = "${pname}-raw";
    inherit version src;

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/lidarr
      cp -a . $out/share/lidarr/
      runHook postInstall
    '';
  };
in
buildFHSEnv {
  name = "Lidarr";
  targetPkgs = _: [
    dotnetCorePackages.aspnetcore_8_0
    icu
    openssl
    sqlite
    zlib
    krb5
    libunwind
    stdenv.cc.cc.lib
    lttng-ust_2_12
    alsa-lib
    ffmpeg
  ];
  runScript = "${rawBinaries}/share/lidarr/Lidarr";

  meta = {
    description = "Music collection manager for Usenet and BitTorrent users (Nightly build)";
    homepage = "https://lidarr.servarr.com/";
    license = lib.licenses.gpl3Only;
    mainProgram = "Lidarr";
    platforms = [ "x86_64-linux" ];
  };
}
