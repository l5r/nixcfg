{ lib, pkgs, ... }:
let
  secrets = import ../../secrets/default.nix;
  musicDirectory = "/media/naspool1/media/Music";
  beetsDirectory = "${musicDirectory}/.config/beets";
  beetsConfig = pkgs.writeText "beets-config.yaml" (lib.generators.toYAML { } {
    directory = musicDirectory;
    import = {
      write = true;
      copy = true;
      # reflink = "auto";
      log = "${beetsDirectory}/import.log";
      languages = "nl fr en";
    };
    paths = {
      default = "%the{$albumartist}/$album%aunique{albumartist album,albumtype year label catalognum albumdisambig releasegroupdisambig,()}/$track - $title";
      singleton = "Non-Album/$artist/$title";
      comp = "Compilations/$album%aunique{}/$track - $title";
    };

    plugins = [
      "bpm"
      "chroma"
      "convert"
      "edit"
      "fish"
      "spotify"
      "ftintitle"
      "replaygain"
    ];
    covnert = {
      auto = true;
      never_convert_lossy_files = true;
      format = "flac";
    };
    replaygain = {
      backend = "ffmpeg";
    };

  });
in
{
  users.users.beets = {
    group = "media";
    isSystemUser = true;
    home = musicDirectory;
    hashedPassword = secrets.leander.hashedPassword;
    openssh.authorizedKeys.keys = secrets.ssh.authorizedKeys.keys;
    shell = pkgs.fish;
  };

  environment.systemPackages = [ pkgs.beets ];

  systemd.tmpfiles.rules = [
    "L+ ${beetsDirectory}/config.yaml - - - - ${beetsConfig}"
  ];
}
