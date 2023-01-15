{ lib, python3Packages }:
python3Packages.buildPythonPackage rec {
  pname = "sqlalchemy-json";
  version = "0.5.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-ifgkINu2rOAihTVQZoZTb2Ru4X4vNaGoEM77zm11pkk=";
  };

  buildInputs = [ python3Packages.sqlalchemy python3Packages.six ];
}
