{ lib, pkgs, ... }:
let
  secrets = import ../../secrets;
in
{
  services.nfs.server = {
    enable = true;
    hostName = secrets.ips.storig;
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
