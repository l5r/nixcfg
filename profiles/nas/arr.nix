{ lib, pkgs, config, ... }:
let
  serviceOptions = { enable = true; group = "media"; openFirewall = true; };
  mkServiceOptions = name: serviceOptions // {
    dataDir = "${config.users.users.media.home}/.local/${name}";
  };
in
{
  services.jackett = mkServiceOptions "jackett";
  services.lidarr = mkServiceOptions "lidarr";
  services.radarr = mkServiceOptions "radarr";
  services.sonarr = mkServiceOptions "sonarr";
}
