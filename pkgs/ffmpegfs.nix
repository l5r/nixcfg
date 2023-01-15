{ lib
, fetchFromGitHub
, stdenv

  # Core dependencies
, asciidoc-full
, autoreconfHook
, autoconf-archive
, chromaprint
, doxygen
, ffmpeg
, fuse
, libchardet
, libcue
, mount
, pkg-config
, sqlite
, unixtools
, w3m-batch
}: stdenv.mkDerivation {
  pname = "ffmpegfs";
  version = "2.13-master";

  src = fetchFromGitHub {
    owner = "l5r";
    repo = "ffmpegfs";
    rev = "d8e86350164a6fa1b7ba44706d66161653c634d5";
    sha256 = "130GfrJMHZI587FxnNgchbl+i6UNkt0EMSJ1bWyBwyQ=";
  };

  nativeBuildInputs = [ asciidoc-full autoconf-archive autoreconfHook doxygen pkg-config unixtools.xxd w3m-batch ];
  propagatedBuildInputs = [ ffmpeg fuse libchardet libcue sqlite ];

  enableParallelBuilding = true;

  postPatch = ''
    sed -ie 's/GENERATE_LATEX         = YES/GENERATE_LATEX         = NO/' Doxyfile
  '';

  # Checks require mounting
  doCheck = false;
  checkInputs = [ chromaprint mount ];
  preCheck = ''
    patchShebangs --host test/test_*
  '';
}
