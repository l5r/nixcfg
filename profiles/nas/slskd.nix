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
    services.slskd = {
      enable = true;
      openFirewall = true;
      environmentFile = config.age.secrets.slskd-environment.path;
      nginx = {};
      settings = {
        soulseek = {
          listen_port = secrets.soulseekPort;
          username = "";
        };
        directories = {
          downloads = completeDir;
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

    services.nginx.enable = lib.mkForce false;

    systemd.mounts = [{
      what = "${downloadDir}/slskd";
      where = "/var/lib/private/slskd";
      requires = ["media-naspool1-media.mount"];
      after = ["media-naspool1-media.mount"];
      requiredBy = ["slskd.service"];
      before = ["slskd.service"];
      options = "bind,x-gvs-hide";
      mountConfig.directoryMode = "0700";
    }];


    users.users.slskd.uid = lib.mkForce config.users.users.slskd.uid;
    users.users.slskd.extraGroups = ["media"];
    users.groups.media.gid = lib.mkForce config.users.groups.media.gid;
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
