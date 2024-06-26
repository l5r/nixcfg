{ lib, pkgs, config, ... }:
let
  serviceOptions = { enable = true; group = "media"; openFirewall = true; };
  mkServiceOptions = name: serviceOptions // {
    dataDir = "${config.users.users.media.home}/.local/${name}";
  };
in
{
  # services.jackett = mkServiceOptions "jackett";
  services.lidarr = mkServiceOptions "lidarr";
  services.radarr = mkServiceOptions "radarr";
  services.sonarr = mkServiceOptions "sonarr";

  services.prowlarr.enable = true;

  systemd.tmpfiles.rules = [
    "d ${config.users.users.media.home}/.local/prowlarr 0700 prowlarr media"
  ];
  systemd.mounts =
    let
      requires = [ "media-naspool1-media.mount" ];
    in [{
      what = "${config.users.users.media.home}/.local/prowlarr";
      where = "/var/lib/private/prowlarr";
      requires = requires;
      after = requires;
      requiredBy = ["prowlarr.service"];
      before = ["prowlarr.service"];
      options = "bind,x-gvs-hide";
      mountConfig.directoryMode = "0700";
    }];

  reverseProxy.upstreams = {
    jackett.port = 9117;
    lidarr.port = 8686;
    radarr.port = 7878;
    sonarr.port = 8989;
    prowlarr.port = 9696;
  };
}
