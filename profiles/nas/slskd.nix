{ lib, pkgs, config, inputs, ... }:
let
  secrets = import ../../secrets/default.nix;
  downloadDir = "/media/naspool1/media/Download";
  slskdDir = "${downloadDir}/.slskd/";
  completeDir = "${downloadDir}/Soulseek/";
in
{
  imports = [ ./torrents.nix ];

  systemd.tmpfiles.rules = [
    "d ${slskdDir} 0775 media media"
    "d ${completeDir} 0775 media media"
  ];


  age.secrets.slskd-environment.file = ../../secrets/slskd-environment.age;

  wg-container.containers.torrent.config = { ... }: {
    imports = [ ../../modules/slskd.nix ];
    networking.firewall.allowedTCPPorts = [ secrets.soulseekPort ];
    services.slskd = {
      enable = true;
      package = pkgs.slskd;
      appDir = "/media/naspool1/media/Download/slskd";
      group = "media";
      openFirewall = true;
      environmentFile = config.age.secrets.slskd-environment.path;
      config = {
        directories = {
          downloads = completeDir;
        };
        soulseek = {
          listen_port = secrets.soulseekPort;
        };
        web = {
          url_base = "/slskd";
        };
        filters.search.request = [
          "^\\..*$"
        ];
        shares.filters = [
          ".*/\\."
        ];
        shares.directories = [
          "[Music]/media/naspool1/media/Music/"
        ];
      };
    };

    users.users.slskd.uid = lib.mkForce config.users.users.slskd.uid;
  };
  users.users.slskd = {
    uid = 2002;
    group = "media";
    isSystemUser = true;
  };

  containers.torrent = {
    bindMounts."${downloadDir}" = {
      hostPath = downloadDir;
      isReadOnly = false;
    };
    bindMounts."/media/naspool1/media/Music".hostPath =
      "/media/naspool1/media/Music";
    bindMounts."${config.age.secrets.slskd-environment.path}".hostPath =
      config.age.secrets.slskd-environment.path;
    extraVeths.rpc.forwardPorts = [{ hostPort = 5030; }];
  };
}
