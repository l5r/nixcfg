{ lib, pkgs, config, ... }:
let
  musicDir = config.my.paths.music;
  mediaDataDir = config.my.paths.mediaData;
  navidromeDir = config.services.navidrome.settings.DataFolder;
in
{
  systemd.tmpfiles.rules = [
    "d ${navidromeDir} 0755 navidrome media"
  ];

  systemd.services.navidrome.serviceConfig = {
    WorkingDirectory = lib.mkForce navidromeDir;
    BindPaths = [ navidromeDir ];
    User = "navidrome";
    Group = "media";
  };

  reverseProxy.upstreams.navidrome.port = 4533;

  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = musicDir;
      DataFolder = "${mediaDataDir}/navidrome";

      Address = "127.0.0.1";
    };
  };

  users.users.navidrome = {
    group = "media";
    isSystemUser = true;
  };
}
