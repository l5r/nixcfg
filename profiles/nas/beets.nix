{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets/default.nix;
  musicDirectory = "/media/naspool1/media/Music";
  beetsDirectory = "${musicDirectory}/.config/beets";
  beetsConfigFile = pkgs.writeText "beets-config.yaml" (lib.generators.toYAML { } beetsConfig);
  ytDlpDir = "/media/naspool1/media/Download/yt-dlp";
  ytDlpConfig = pkgs.writeText "yt-dlp.conf" ''
    --write-thumbnail

    --extract-audio
    --embed-thumbnail
    --embed-metadata
    --sponsorblock-remove default
    -f bestaudio

    # Output file template
    -o "${ytDlpDir}/%(extractor)S/%(playlist,genre)S/%(album_artist,artist,creator,uploader,channel)S/%(album,series|Non-Album)S/%(title)S.%(ext)s"
    --download-archive "${ytDlpDir}/00-yt-dlp.txt"
  '';
  ytDlpBatchFile = pkgs.writeText "yt-dlp-batch.txt"
    (builtins.concatStringsSep "\n" secrets.beets-yt-dlp-urls);
  beetsConfig = {
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
      # "chroma"
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
    chroma.auto = false;
    convert = {
      auto = true;
      never_convert_lossy_files = true;
      format = "flac";
      formats = {
        aac = {
          command = "ffmpeg -i $source -y -vn -acodec aac -aac_pns 0 -b:a 256k $dest";
          extension = "m4a";
        };
      };
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
      youtubedl_options = let yt-dlpDir = ytDlpDir; in
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
  };
  beetsExportConfigFile = pkgs.writeText "beets-config.yaml" (lib.generators.toYAML { } beetsExportConfig);
  beetsExportConfig = lib.recursiveUpdate beetsConfig {
    convert = {
      never_convert_lossy_files = false;
      no_convert="format:mp3";
      format = "aac";
    };
  };
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

  environment.systemPackages = [ pkgs.beets pkgs.ffmpegfs pkgs.ffmpeg pkgs.tmux pkgs.yt-dlp ];

  systemd.tmpfiles.rules = [
    "d ${beetsDirectory} 0775 media media"
    "L+ ${beetsDirectory}/config.yaml - - - - ${beetsConfigFile}"
    "L+ ${beetsDirectory}/config-export.yaml - - - - ${beetsExportConfigFile}"
    "L+ ${beetsDirectory}/yt-dlp.conf - - - - ${ytDlpConfig}"
    "L+ ${beetsDirectory}/yt-dlp-batch.txt - - - - ${ytDlpBatchFile}"
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
