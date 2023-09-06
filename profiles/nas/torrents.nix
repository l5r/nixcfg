{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets/default.nix;
  torrentDir = "/media/naspool1/media/Download/Torrent";
  vpnInterface = "wg-torrent";
in
{
  imports = [ ../../modules/wg-container.nix ];

  systemd.tmpfiles.rules = [
    "d ${torrentDir} 0775 media media"
  ];
  networking.firewall.allowedTCPPorts = [ 9091 ];

  age.secrets.wireguard-private = {
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };

  age.secrets.wireguard-psk = {
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };

  wg-container = {
    enable = true;
    containers.torrent = {
      enable = true;
      privateKeyFile = config.age.secrets.wireguard-private.path;
      wireguardPeerConfig = secrets.wireguardPeerConfig // {
        PresharedKeyFile = config.age.secrets.wireguard-psk.path;
      };
      wireguardIPs = secrets.wireguardIPs;
      dns = [ "10.4.0.1" "fde6:7a:7d20:4::1" "1.1.1.1" ];

      config = { lib, pkgs, ... }: {
        system.activationScripts.remove-default-route-via-host = ''
          ${pkgs.iproute2}/bin/ip route del default via 10.1.1.1 || true
        '';

        users.groups.media.gid = config.users.groups.media.gid;
        users.users.transmission = {
          uid = lib.mkForce config.users.users.transmission.uid;
          isSystemUser = true;
        };

        services.transmission = {
          enable = true;
          group = "media";
          home = torrentDir;
          downloadDirPermissions = "775";
          openPeerPorts = true;
          openRPCPort = true;

          settings = {
            download-dir = "${torrentDir}/Complete";
            incomplete-dir = "${torrentDir}/Partial";
            watch-dir = "${torrentDir}/Watch";
            watch-dir-enabled = true;
            peer-port = secrets.torrentPort;
            rpc-whitelist = "127.0.0.1,10.1.1.*,192.168.1.*,172.24.*.*";
            rpc-host-whitelist = "storig,transmission.${secrets.virtualHostnames.internal.hostname}";
            rpc-bind-address = "10.1.1.2";
            dht-enabled = false;
          };
        };
        system.stateVersion = "22.11";
      };
    };
  };

  containers.torrent = {
    bindMounts."${torrentDir}" = {
      hostPath = torrentDir;
      isReadOnly = false;
    };

    ephemeral = true;
    autoStart = true;

    extraVeths.rpc = {
      hostAddress = "10.1.1.1";
      localAddress = "10.1.1.2";

      forwardPorts = [{ hostPort = 9091; }];
    };
  };

  systemd.services."container@torrent" = {
    requires = [ "media-naspool1-media.mount" ];
    after = [ "media-naspool1-media.mount" ];
  };

  ids.uids.transmission = lib.mkForce 2001;
  users.users.transmission = {
    uid = config.ids.uids.transmission;
    isSystemUser = true;
    group = "media";
  };
}
