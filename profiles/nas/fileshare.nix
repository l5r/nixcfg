{ lib, pkgs, ... }:
let
  secrets = import ../../secrets;
in
{
  networking.firewall.allowedTCPPorts = [
    # NFS
    2049
    # wssd
    5357
  ];
  networking.firewall.allowedUDPPorts = [
    # wssd
    3702
  ];

  services.nfs.server = {
    enable = true;
    hostName = secrets.ips.storig;
    exports = ''
      /media/naspool1 172.24.0.0/16(ro,insecure,sync,no_subtree_check,crossmnt,fsid=0)
      /media/naspool1/media 172.24.0.0/16(rw,insecure,sync,no_subtree_check,crossmnt,anonuid=2000,anongid=2000,all_squash)
    '';
  };

  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        "hosts allow" = "192.168.1.0/24 172.24.0.0/16 127.0.0.1 ::1";
        "hosts deny" = "0.0.0.0/0";
        "interfaces" = "192.168.1.0/24 172.24.0.0/16";
        # "server smb encrypt" = "no";
        "server max protocol" = "SMB3";
        "server min protocol" = "SMB3_00";
        "map to guest" = "bad user";
        "guest account" = "media";
        "server string" = "storig";
        "netbios name" = "storig";
        "use sendfile" = "yes";
        "fruit:copyfile" = "yes";
      };
      media = {
        path = "/media/naspool1/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "public" = "yes";
        "force user" = "media";
        "force group" = "media";
        "fruit:aapl" = "yes";
      };
    };
  };
}
