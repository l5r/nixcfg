{ config, lib, pkgs, ... }:
let
  secrets = import ../../secrets;
  nasFsOpts = {
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=${toString (60 * 30)}"
      "noauto"
      "nofail"
      "nfsvers=4.2"
    ];
  };
in
{
  fileSystems = {

    "/media/naspool1/media" = nasFsOpts // {
      device = "${secrets.ips.storig}:/media";
    };

  };

  networking.hosts."${secrets.ips.storig}" = [ "storig" ];
}
