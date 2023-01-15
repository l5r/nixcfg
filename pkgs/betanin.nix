{ lib, fetchFromGitHub, beets, python3Packages, python3 }:

python3Packages.buildPythonPackage rec {
  pname = "betanin";
  version = "0.3.41";

  src = fetchFromGitHub {
    owner = "sentriz";
    repo = "betanin";
    rev = "3e46260d695206b2fae25afb0e71f17b8cd761ff";
    sha256 = "Nu1jrP3+cmJotnlZRPDMC+N4TNWUapHsIdCxdOL7Kmo=";
  };

  patches = [
    ../patches/betanin-setup-version.patch
    ../patches/betanin-werkzeug-proxyfix.patch
  ];
  postPatch = ''
    sed -i -e 's/%BETANIN_VERSION%/${version}/g' setup.py

    sed -i -re 's/[>=]=[0-9]+(\.[0-9]+)*",/",/g' setup.py
  '';

  propagatedBuildInputs = with python3Packages; [
    aniso8601
    apprise
    attrs
    beets
    flask-cors
    flask-jwt-extended
    flask-restplus
    flask-socketio
    flask_migrate
    gevent
    greenlet
    importlib-metadata
    jsonschema
    loguru
    ptyprocess
    python-editor
    python-socketio
    requests
    sqlalchemy-json
    sqlalchemy-utils
    toml
    typing-extensions
    tzlocal
    werkzeug
    unidecode
    zipp
    zope_interface
  ];

  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest
    runHook postCheck
  '';
}
