{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;

  internal = secrets.virtualHostnames.internal.hostname;
  external = secrets.virtualHostnames.external.hostname;
in
{
  imports = [
    ../../modules/reverse-proxy.nix
  ];

  reverseProxy = {
    enable = true;

    upstreams = {
      owntone.port = 3689;
      transmission = { host = "10.1.1.2"; port = 9091; };
    };

    downstreams = {
      internal = {
        implementation = "nginx";
        host = internal;
        default = true;

        nginxOptions = {
          listenAddresses = [ secrets.ips.storig ];
          useACMEHost = internal;
          forceSSL = true;
        };
      };
      external = {
        implementation = "cloudflared";
        host = external;
        default = false;

        cloudflaredTunnelID = secrets.cloudflaredTunnelID;
        cloudflaredCredentialsFile = config.age.secrets.cloudflared-tunnel-external-credentials.path;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];


  services.nginx = {
    enable = true;
    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts.${internal} = {
      default = true;
      addSSL = true;
      useACMEHost = internal;

      listenAddresses = [ secrets.ips.storig ];
    };
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
      default = "http_status:404";
      ingress = {
        ${external} = "http_status:204";
      };
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
