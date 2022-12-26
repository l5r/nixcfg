{ lib, pkgs, config, ... }:
let
  mediaDir = "/media/naspool1/media";
in
{
  imports = [
    ./beets.nix
    ./torrents.nix
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
  systemd.services.jellyfin.serviceConfig.PrivateDevices = lib.mkForce false;

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0775 media media"
    "d ${mediaDir}/.local 0775 media media"
    "d ${mediaDir}/Download 0775 media media"
    "d ${mediaDir}/Music 0775 media media"
    "d ${mediaDir}/Music/.config 0775 media media"
    "d ${mediaDir}/Movies/ 0775 media media"
    "d ${mediaDir}/TV/ 0775 media media"

    "d ${mediaDir}/.local/jellyfin 0775 jellyfin media"
    "L /var/lib/jellyfin/ 0775 jellyfin media - ${mediaDir}/.local/jellyfin/"
  ];
}
