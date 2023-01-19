{ lib, pkgs, config, ... }:
let dataDir = "/media/naspool1/data";
in
{
  imports = [
    ./portunus.nix
  ];

  users.users.data = {
    uid = 3000;
    isSystemUser = true;
    group = "data";
    home = dataDir;
  };
  users.groups.data.gid = 3000;

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0775 data data"
    "d ${dataDir}/System 0775 data data"
    "d ${dataDir}/Documents 0775 data data"
  ];
}
