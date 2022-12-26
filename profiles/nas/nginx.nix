{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;
in
{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    defaultListenAddresses = [ secrets.ips.storig ];

    virtualHosts."storig" = {
      default = true;
      locations =
        let
          proxy = name: port: {
            proxyPass = "http://127.0.0.1:" + toString (port) + "/${name}";
            proxyWebsockets = true;
          };
        in
        {
          "/jackett" = proxy "jackett" 9117;
          "/lidarr" = proxy "lidarr" 8686;
          "/radarr" = proxy "radarr" 7878;
          "/sonarr" = proxy "sonarr" 8989;
          "/jellyfin" = proxy "jellyfin" 8096;

          "/transmission".proxyPass = "http://10.1.1.2:9091/transmission";
        };
    };
  };
}
