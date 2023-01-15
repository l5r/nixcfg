{ callPackage }: {
  beetsPackages = {
    beets-yt-dlp = callPackage ./beets-yt-dlp.nix { };
    beets-bpmanalyser = callPackage ./beets-bpmanalyser.nix { };
  };
  betanin = callPackage ./betanin.nix { };
  ffmpegfs = callPackage ./ffmpegfs.nix { };
  slskd = callPackage ./slskd { };
  sqlalchemy-json = callPackage ./sqlalchemy-json.nix { };
}
