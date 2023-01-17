{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;

  upstreams = {
    jellyfin.port = 8096;
  };

  upstreamToVirtualHostConfig =
    { host ? "127.0.0.1", port, ... }: {
      locations."/" = {
        proxyPass = "http://${host}:${builtins.toString port}";
        proxyWebsockets = true;
      };
    };

  upstreamToHostnames = config': lib.flatten (
    let config = { internal = true; external = false; } // config'; in
    lib.mapAttrsToList (name: value: lib.optional config.${name} value)
      secrets.virtualHostnames
  );

  upstreamToVirtualHosts = name: config:
    builtins.map
      ({ hostname, extraConfig ? { } }: {
        "${name}.${hostname}" = extraConfig // upstreamToVirtualHostConfig config;
      })
      (upstreamToHostnames config);

  virtualHostList = lib.flatten (lib.mapAttrsToList upstreamToVirtualHosts upstreams);
in
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    defaultListenAddresses = [ secrets.ips.storig ];

    virtualHosts = lib.mkMerge (virtualHostList ++ [{
      "storig" = {
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
            "/owntone" = proxy "" 3689;
            "/radarr" = proxy "radarr" 7878;
            "/sonarr" = proxy "sonarr" 8989;
            "/jellyfin" = proxy "jellyfin" 8096;

            "/slskd".proxyPass = "http://10.1.1.2:5000/slskd";
            "/transmission".proxyPass = "http://10.1.1.2:9091/transmission";
          };
      };
    }]);
  };

  age.secrets.acme-credentials = {
    file = ../../secrets/acme-credentials.age;
    mode = "0400";
    owner = "acme";
    group = "acme";
  };

  security.acme = lib.recursiveUpdate secrets.acme {
    acceptTerms = true;
    preliminarySelfsigned = true;
    defaults.credentialsFile = config.age.secrets.acme-credentials.path;
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
