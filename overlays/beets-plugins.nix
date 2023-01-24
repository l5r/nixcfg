final: prev:
let
  callBeetsPlugin = path: final.callPackage path {
    beets = final.beetsPackages.beets-minimal;
  };
in
prev.lib.recursiveUpdate prev {
  beetsPackages.yt-dlp = callBeetsPlugin ../pkgs/beets-yt-dlp.nix;
  beetsPackages.bpmanalyser = callBeetsPlugin ../pkgs/beets-bpmanalyser.nix;

  python3 = prev.python3.override {
    packageOverrides = pFinal: pPrev: {
      sqlalchemy-json = final.callPackage ../pkgs/sqlalchemy-json.nix
        { python3Packages = pFinal; };
      aubio = pPrev.aubio.overridePythonAttrs (prev: {
        nativeBuildInputs = prev.buildInputs ++ [
          final.pkg-config
        ];
        propagatedBuildInputs =
          (prev.propagatedBuildInputs or [ ]) ++
          [ final.ffmpeg.out.dev ];
      });
    };
  };
  python3Packages = final.python3.pkgs;

  beetsPackages.beets-stable = prev.beetsPackages.beets-stable.override {
    pluginOverrides = {
      yt-dlp = {
        enable = true;
        propagatedBuildInputs = [
          final.beetsPackages.yt-dlp
        ];
      };
      bpmanalyser = {
        enable = true;
        propagatedBuildInputs = [
          final.beetsPackages.bpmanalyser
          final.aubio
        ];
      };
    };
  };
  beets = final.beetsPackages.beets-stable;
}
