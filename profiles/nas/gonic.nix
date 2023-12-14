{ lib, config, ... }:
let
  musicDir = config.my.paths.music;
  podcastDir = config.my.paths.podcasts;
  mediaDataDir = config.my.paths.mediaData;
  gonicDir = "${mediaDataDir}/gonic";
  playlistDir = "/var/lib/gonic/playlists";
in {
  # systemd.tmpfiles.rules = builtins.map
  #   (i: "L /var/lib/private/gonic/playlists/${builtins.toString i} 0755 media media - ${musicDir}/Playlists")
  #   (lib.lists.genList lib.id 10);

  services.gonic = {
    enable = true;
    settings = {
      music-path = musicDir;
      playlists-path = "${musicDir}/Playlists";
      podcast-path = podcastDir;
    };
  };

  systemd.services.gonic.serviceConfig = {
    BindPaths =  ["${musicDir}/Playlists:${musicDir}/Playlists/1"];
    BindReadOnlyPaths = [
      "/etc/resolv.conf"
    ];
  };

  systemd.mounts =
    let
      requires = [ "media-naspool1-media.mount" ];
    in [{
      what = "${gonicDir}";
      where = "/var/lib/private/gonic";
      requires = requires;
      after = requires;
      requiredBy = ["gonic.service"];
      before = ["gonic.service"];
      options = "bind,x-gvs-hide";
      mountConfig.directoryMode = "0700";
    }];

    reverseProxy.upstreams = {
      gonic.port = 4747;
    };
}
