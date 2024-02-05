{ lib, pkgs, config, ... }:
let mediaDir = "/media/naspool1/media";
in
{
  imports = [
    ./beets.nix
    ./gonic.nix
    # ./navidrome.nix
    # ./owntone.nix
    ./torrents.nix
    ./slskd.nix
    ./arr.nix
  ];

  users.users.media = {
    uid = 2000;
    isSystemUser = true;
    group = "media";
    home = mediaDir;
  };
  users.groups.media.gid = 2000;

  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
  users.users.jellyfin.extraGroups = [ "video" "render" ];
  systemd.services.jellyfin.serviceConfig.PrivateDevices = lib.mkForce false;
  reverseProxy.upstreams.jellyfin = {
    url = "http://127.0.0.1:8096";
    downstreams = ["internal" "external"];
  };

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0775 media media"
    "d ${mediaDir}/.local 0775 media media"
    "d ${mediaDir}/Download 0775 media media"
    "d ${mediaDir}/Music 0775 media media"
    "d ${mediaDir}/Music/.config 0775 media media"
    "d ${mediaDir}/Movies/ 0775 media media"
    "d ${mediaDir}/TV/ 0775 media media"

    "d ${mediaDir}/.local/jellyfin 0775 jellyfin media"
    # "L /var/lib/jellyfin/ 0700 jellyfin media - ${mediaDir}/.local/jellyfin/"
  ];

  systemd.mounts =
    let
      requires = [ "media-naspool1-media.mount" ];
    in
    [{
      what = "${mediaDir}/.local/jellyfin";
      where = "/var/lib/jellyfin";
      requires = requires;
      # after = requires;
      requiredBy = [ "jellyfin.service" ];
      before = [ "jellyfin.service" ];
      options = "bind,x-gvs-hide";
    }];

  systemd.automounts = [{
    where = "/var/lib/jellyfin";
  }];
}
