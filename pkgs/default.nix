{ callPackage }: {
  beetsPackages = {
    beets-yt-dlp = callPackage ./beets-yt-dlp.nix { };
    beets-bpmanalyser = callPackage ./beets-bpmanalyser.nix { };
  };
  betanin = callPackage ./betanin.nix { };
  ffmpegfs = callPackage ./ffmpegfs.nix { };
  owntone = callPackage ./owntone.nix { };
  owntoneMinimal = callPackage ./owntone.nix { withDefault = false; };
  owntoneFull = callPackage ./owntone.nix { withAll = true; };
  slskd = callPackage ./slskd { };
  sqlalchemy-json = callPackage ./sqlalchemy-json.nix { };
}
