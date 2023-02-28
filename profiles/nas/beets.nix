{ lib, pkgs, config, ... }:
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
      incremental = true;
      log = "${beetsDirectory}/import.log";
      languages = "nl fr en";
    };
    paths = {
      default = "Album/%the{$albumartist}/$album%aunique{albumartist album,albumtype year label catalognum albumdisambig releasegroupdisambig,()}/%if{$multidisc,$media $disc - }$track - $title";
      singleton = "Non-Album/$artist/$title";
      comp = "Compilations/$album%aunique{}/%if{$multidisc,$media $disc - }$track - $title";
    };

    plugins = [
      "bpmanalyser"
      "chroma"
      "convert"
      "duplicates"
      "edit"
      "fish"
      "fetchart"
      "inline"
      "keyfinder"
      "lastgenre"
      "smartplaylist"
      "spotify"
      "the"
      "ydl"
      "ftintitle"
      "replaygain"
    ];
    bpmanalyser.auto = true;
    chroma.auto = true;
    convert = {
      auto = true;
      never_convert_lossy_files = true;
      format = "flac";
    };
    fetchart = {
      auto = true;
    };
    item_fields = {
      multidisc = "1 if disctotal > 1 else 0";
    };
    keyfinder = {
      auto = true;
      bin = "keyfinder-cli";
    };
    replaygain = {
      backend = "ffmpeg";
    };
    smartplaylist = {
      relative_to = "${musicDirectory}/Playlists";
      playlist_dir = "${musicDirectory}/Playlists";
      playlists = [
        { name = "BPM.m3u8"; query = "bpm+"; }
      ];
    };
    ydl = {
      keep_files = true;
      youtubedl_options = let yt-dlpDir = "/media/naspool1/media/Download/yt-dlp"; in
        {
          cachedir = "${yt-dlpDir}/cache";
          download_archive = "${yt-dlpDir}/00-yt-dlp.tx";
          outtmpl = {
            default =
              "%(extractor)S/%(playlist,genre)S/%(album_artist,artist,creator,uploader,channel)S/%(album,series|Non-Album)S/%(title)S.%(ext)s";
          };
          paths = {
            home = yt-dlpDir;
          };
          outtmpl_na_placeholder = "Other";
          writethumbnail = true;
          format = "bestaudio";
          postprocessors = [
            {
              key = "FFmpegExtractAudio";
              preferredcodec = "best";
              nopostoverwrites = true;
            }
            { key = "SponsorBlock"; }
            { key = "FFmpegMetadata"; }
            # { key = "EmbedThumbnail"; }
          ];

          source_address = "192.168.1.200";
          sleep_interval_requests = 2;
        };
      urls = secrets.beets-yt-dlp-urls;
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

  environment.systemPackages = [ pkgs.beets pkgs.ffmpegfs pkgs.ffmpeg ];

  systemd.tmpfiles.rules = [
    "L+ ${beetsDirectory}/config.yaml - - - - ${beetsConfig}"
  ];

  fileSystems."/media/naspool1/media/iTunes" = {
    device = "${pkgs.ffmpegfs}/bin/ffmpegfs#${musicDirectory}";
    depends = [ "/dev/fuse" "/media/naspool1" "/media/naspool1/media" ];
    fsType = "fuse";
    options = [
      "allow_other"
      "ro"
      "audiobitrate=320K"
      "desttype=m4a"
      "autocopy=match"
      "oldnamescheme=1"
      "include_extensions=flac\\,ogg\\,opus"
      "nofail"
      "x-systemd.requires=media-naspool1-media.mount"
    ];
  };

  systemd.mounts = [{
    where = "/media/naspool1/media/iTunes";
    what = "${pkgs.ffmpegfs}/bin/ffmpegfs#${musicDirectory}";
    type = "fuse";
    after = [ "media-naspool1-media.mount" "sys-fs-fuse-connections.mount" ];
    wants = [ "media-naspool1-media.mount" "sys-fs-fuse-connections.mount" ];
    wantedBy = [ "multi-user.target" ];
    options = "allow_other,ro,audiobitrate=320K,desttype=m4a,autocopy=match,oldnamescheme=1,include_extensions=flac\\,ogg\\,opus,nofail,log_stderr";
  }];
}
