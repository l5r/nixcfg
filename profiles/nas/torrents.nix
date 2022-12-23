{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets/default.nix;
  torrentDir = "/media/naspool1/media/Download/Torrent";
  vpnInterface = "wg-torrent";
in
{
  systemd.tmpfiles.rules = [
    "d ${torrentDir} 0775 media media"
    # "d ${torrentDir}/Done 0775 media media"
    # "d ${torrentDir}/Progress 0775 media media"
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

  containers.torrent = {

    bindMounts."${torrentDir}" = {
      hostPath = torrentDir;
      isReadOnly = false;
    };

    ephemeral = true;
    autoStart = true;

    privateNetwork = true;
    interfaces = [ vpnInterface ];

    config = { lib, pkgs, ... }: {
      services.transmission.enable = false;

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

      system.stateVersion = "22.11";
    };
  };

  systemd.services."container@torrent" =
    let
      interfaceService = "sys-subsystem-net-devices-wg\\x2dtorrent.device";
    in
    {
      requires = [ interfaceService ];
      after = [ interfaceService ];
    };
}
