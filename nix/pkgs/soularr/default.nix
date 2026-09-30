{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
  stdenv,
}:
let
  version = "1.2.2";

  slskd-api = python3.pkgs.buildPythonPackage rec {
    pname = "slskd-api";
    version = "0.1.5";

    pyproject = true;
    build-system = [ python3.pkgs.setuptools ];

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-LmWP7bnK5IVid255qS2NGOmyKzGpUl3xsO5vi5uJI88=";
    };

    postPatch = ''
      sed -i \
        -e '/setuptools_git_versioning={/,/},/d' \
        -e '/setup_requires = \["setuptools-git-versioning"\]/d' \
        -e "/name='slskd-api',/a\\    version='${version}'," \
        setup.py
    '';

    propagatedBuildInputs = [ python3.pkgs.requests ];
    doCheck = false;

    meta.license = lib.licenses.agpl3Only;
  };

  pyarr = python3.pkgs.buildPythonPackage rec {
    pname = "pyarr";
    version = "5.2.0";

    pyproject = true;
    build-system = [ python3.pkgs.poetry-core ];

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-jlcc9Kj1MYSsnvJkKZXXWWJVDx3KIuojjbGtl8kDUpw=";
    };

    nativeBuildInputs = [ python3.pkgs.pythonRelaxDepsHook ];
    pythonRelaxDeps = [ "types-requests" ];

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-warn "poetry.masonry.api" "poetry.core.masonry.api"
    '';

    propagatedBuildInputs = with python3.pkgs; [
      requests
      overrides
      types-requests
    ];
    doCheck = false;

    meta.license = lib.licenses.mit;
  };

  music-tag = python3.pkgs.buildPythonPackage rec {
    pname = "music-tag";
    version = "0.4.3";

    pyproject = true;
    build-system = [ python3.pkgs.setuptools ];

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Cqtubu2o3w9TFuwtIZC9dFYbfgNWKrCRzo1Wh828//Y=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      mutagen
      pillow
    ];
    doCheck = false;

    meta.license = lib.licenses.mit;
  };

  pythonEnv = python3.withPackages (ps: [
    ps.flask
    ps.waitress
    slskd-api
    pyarr
    music-tag
  ]);
in
stdenv.mkDerivation {
  pname = "soularr";
  inherit version;

  src = fetchFromGitHub {
    owner = "mrusse";
    repo = "soularr";
    rev = "v${version}";
    hash = "sha256-gtz99+DiFjJZuq54qo5C+5Exx++S+ePzldgDM9NHAOB=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/soularr $out/bin
    cp -r soularr.py webui resources $out/share/soularr/

    makeWrapper ${pythonEnv}/bin/python $out/bin/soularr \
      --add-flags "$out/share/soularr/soularr.py"

    makeWrapper ${pythonEnv}/bin/python $out/bin/soularr-webui \
      --add-flags "$out/share/soularr/webui/webui.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Connects Lidarr with Soulseek (via slskd) to auto-download wanted albums";
    homepage = "https://github.com/mrusse/soularr";
    license = licenses.gpl3Only;
    mainProgram = "soularr";
    platforms = platforms.linux;
  };
}
