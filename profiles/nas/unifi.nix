{ config, ... }:
let
  dataDir = config.my.paths.data;
in
{
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  reverseProxy.upstreams.unifi = { scheme = "https"; port = 8443; };

  systemd.tmpfiles.rules = [
    "d ${dataDir}/System/var/lib/unifi 0770 unifi data"
  ];
  fileSystems."/var/lib/unifi" = {
    device = "${dataDir}/System/var/lib/unifi";
    options = [ "bind" ];
  };
}
