{ lib, pkgs, ... }: {
  imports = [
    ./beets.nix
    ./torrents.nix
  ];

  users.users.media = {
    uid = 2000;
    isSystemUser = true;
    group = "media";
  };
  users.groups.media.gid = 2000;

  systemd.tmpfiles.rules = [
    "d /media/naspool1/media 0775 media media"
    "d /media/naspool1/media/Download 0775 media media"
    "d /media/naspool1/media/Music 0775 media media"
    "d /media/naspool1/media/Music/.config 0775 media media"
  ];
}
