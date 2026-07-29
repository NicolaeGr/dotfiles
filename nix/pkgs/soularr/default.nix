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
      sha256 = "2e658fedb9cae48562776e79a92d8d18e9b22b31a9525df1b0ee6f8b9b8923cf";
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
      sha256 = "8e571cf4a8f53184ac9ef2642995d75962550f1dca22ea238db1ad97c903529c";
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
      sha256 = "0aab6e6eeda8df0f5316ec2d2190bd74561b7e03562ab091ce8d5687cdbcfff6";
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
    hash = "sha256-gtz99+DiFjJZuq54qo5C+5Exx++S+ePzldgDM9NHAOA=";
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
