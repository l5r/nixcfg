{ lib, fetchFromGitHub, beets, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "beets-yt-dlp";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "l5r";
    repo = "beets-yt-dlp";
    rev = "ae893c77d95543f8ea908bf5a1843bfc4e7e794e";
    sha256 = "YnimagFckamFQJZVi4iuaq6mH47zs0VAVHr2P39z7fM=";
  };
  propagatedBuildInputs = [ python3Packages.yt-dlp python3Packages.pyxdg ];
  checkInputs = [ beets ];

  meta = {
    homepage = "https://github.com/l5r/beets-yt-dlp";
    description = "Download audio from yt-dlp sources and import into beets";
  };
}
