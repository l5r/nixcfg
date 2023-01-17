{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;

  upstreams = {
    jellyfin.port = 8096;
    jackett.port = 9117;
    lidarr.port = 8686;
    owntone.port = 3689;
    radarr.port = 7878;
    sonarr.port = 8989;
    slskd = { host = "10.1.1.2"; port = 5000; };
    transmission = { host = "10.1.1.2"; port = 9091; };
  };

  defaultUpstreamSettings = {
    internal = true;
    external = false;
    host = "127.0.0.1";
  };

  upstreamsWithDefaults = lib.mapAttrs (_: v: defaultUpstreamSettings // v) upstreams;

  upstreamToVirtualHostConfig =
    { host ? "127.0.0.1", port, ... }: {
      locations."/" = {
        proxyPass = "http://${host}:${builtins.toString port}";
        proxyWebsockets = true;
      };
    };

  upstreamToHostnames = config: lib.flatten (
    lib.mapAttrsToList (name: value: lib.optional config.${name} value)
      secrets.virtualHostnames
  );

  upstreamToVirtualHosts = name: config:
    builtins.map
      ({ hostname, extraConfig ? { } }: {
        "${name}.${hostname}" = extraConfig // upstreamToVirtualHostConfig config;
      })
      (upstreamToHostnames config);

  virtualHostList = lib.flatten (lib.mapAttrsToList upstreamToVirtualHosts upstreamsWithDefaults);
in
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    defaultListenAddresses = [ secrets.ips.storig ];

    virtualHosts = lib.mkMerge (virtualHostList ++ [{
      "storig" = {
        serverAliases = [
          secrets.virtualHostnames.internal.hostname
          secrets.ips.storig
        ];
        listen = [
          { port = 80; addr = "127.0.0.1"; }
          { port = 80; addr = secrets.ips.storig; }
        ];
      };
      ${secrets.virtualHostnames.external.hostname} = {
        default = true;
        listen = [
          { port = 80; addr = "127.0.0.1"; }
        ];
      };
    }]);
  };

  age.secrets.cloudflared-tunnel-external-credentials = {
    file = ../../secrets/cloudflared-tunnel-external-credentials.age;
    mode = "0400";
    owner = "cloudflared";
    group = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels.${secrets.cloudflaredTunnelID} = {
      credentialsFile = config.age.secrets.cloudflared-tunnel-external-credentials.path;
      default = "http_status:404";
      ingress =
        let
          hostname = secrets.virtualHostnames.external.hostname;
          upstreamsExternal = lib.filterAttrs (n: v: v.external) upstreamsWithDefaults;
          mkUpstreamIngress = name: { host, port, ... }: {
            "${name}.${hostname}" = "http://${host}:${port}";
          };
          ingresses =
            (lib.mapAttrsToList mkUpstreamIngress upstreamsExternal) ++ [{
              ${hostname} = "http://localhost";
            }];
        in
        lib.mkMerge ingresses;
    };
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
