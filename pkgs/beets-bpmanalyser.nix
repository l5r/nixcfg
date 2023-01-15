{ lib, beets, aubio, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "beets-bpmanalyser";
  version = "1.3.3";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-xeXOjnkZZV1CubPmAojFH9kh1LBV2k4BJADje8Ef7PQ=";
  };
  patches = ../patches/beets-bpmanalyser-script.patch;

  propagatedBuildInputs = [ python3Packages.numpy python3Packages.aubio ];
  buildInputs = [ beets ];
  checkInputs = with python3Packages; [ beets pytest mock coverage nose six ];
  doCheck = false;

  meta = {
    homepage = "https://github.com/adamjakab/BeetsPluginBpmAnalyser/";
    description = ''
      The beets-bpmanalyser plugin lets you analyse the tempo of the songs you
      have in your library and write the bpm information on the bpm tag of your
      media files.
    '';
  };
}
