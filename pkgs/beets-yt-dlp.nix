{ lib, fetchFromGitHub, beets, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "beets-yt-dlp";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "l5r";
    repo = "beets-yt-dlp";
    rev = "cceb1205ec14241ed072a255f3db3b06b8307c0b";
    sha256 = "+mTvwhPcCim8+60/Gmokj3h5nviep533DFRV4GsiWJA=";
  };
  propagatedBuildInputs = [ python3Packages.yt-dlp python3Packages.pyxdg ];
  checkInputs = [ beets ];

  meta = {
    homepage = "https://github.com/l5r/beets-yt-dlp";
    description = "Download audio from yt-dlp sources and import into beets";
  };
}
