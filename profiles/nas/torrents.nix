{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets/default.nix;
  torrentDir = "/media/naspool1/media/Download/Torrent";
  vpnInterface = "wg-torrent";
in
{
  systemd.tmpfiles.rules = [
    "d ${torrentDir} 0775 media media"
  ];

  age.secrets.wireguard-private = {
    mode = "440";
    owner = "root";
    group = "systemd-network";
  };

  systemd.network = {
    enable = true;
    wait-online = {
      anyInterface = true;
      ignoredInterfaces = [ vpnInterface ];
    };
    netdevs."10-${vpnInterface}" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = vpnInterface;
        MTUBytes = "1400";
      };
      wireguardConfig = {
        PrivateKeyFile = config.age.secrets.wireguard-private.path;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = secrets.wireguardPeerConfig // {
            AllowedIPs = "0.0.0.0/0,::/0";
          };
        }
      ];
    };
    networks."40-${vpnInterface}" = {
      dns = [ "10.64.0.1" ];
      address = secrets.wireguardIPs;
      matchConfig.Name = vpnInterface;
    };
  };

  systemd.services."container@torrent" =
    let
      interfaceService = "sys-subsystem-net-devices-wg\\x2dtorrent.device";
    in
    {
      requires = [ interfaceService "systemd-networkd-wait-online.service" ];
      after = [ interfaceService "systemd-networkd-wait-online.service" ];
    };

  networking.firewall.allowedTCPPorts = [ 9091 ];

  containers.torrent = {

    bindMounts."${torrentDir}" = {
      hostPath = torrentDir;
      isReadOnly = false;
    };

    ephemeral = true;
    autoStart = true;

    privateNetwork = true;
    interfaces = [ vpnInterface ];
    extraVeths.rpc = {
      hostAddress = "10.1.1.1";
      localAddress = "10.1.1.2";

      forwardPorts = [{ hostPort = 9091; }];
    };

    config = { lib, pkgs, ... }: {
      networking.useHostResolvConf = false;
      systemd.network = {
        enable = true;
        networks."40-${vpnInterface}" = {
          dns = [ "10.64.0.1" ];
          matchConfig.Name = vpnInterface;
          address = secrets.wireguardIPs;
          gateway = [ "0.0.0.0" "::" ];
        };
      };

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
          rpc-whitelist = "127.0.0.1,10.1.1.*,192.168.1.*";
          rpc-bind-address = "10.1.1.2";
        };
      };

      system.stateVersion = "22.11";
    };
  };

  ids.uids.transmission = lib.mkForce 2001;
  users.users.transmission = {
    uid = config.ids.uids.transmission;
    isSystemUser = true;
    group = "media";
  };
}
