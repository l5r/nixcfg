{ lib, config, options, pkgs, utils, ... }:
let
  cfg = config.reverseProxy;
  types = lib.types;

  upstreamOptions = { config, ... }: {
    options = {
      scheme = lib.mkOption {
        type = types.str;
        default = "http";
        description = lib.mdDoc ''
          the URL scheme used for the upstream connection
        '';
      };
      host = lib.mkOption {
        type = types.str;
        default = "localhost";
        description = lib.mdDoc ''
          This is the host(name) used as a base.
        '';
      };
      port = lib.mkOption {
        type = types.nullOr types.port;
        description = lib.mdDoc ''
          The port at which to connect to the upstream.
        '';
      };
      path = lib.mkOption {
        type = types.str;
        default = "/";
        description = lib.mdDoc ''
          This is the path under which the upstreams are placed.
        '';
      };
      url = lib.mkOption {
        type = types.str;
      };

      downstreams = lib.mkOption {
        type = types.listOf types.str;
        default = lib.flatten
          (lib.mapAttrsToList
            (name: { default, ... }: lib.optional default name)
            cfg.downstreams);
      };
    };

    config.url =
      let
        port = lib.optionalString (config.port != null) ":${builtins.toString config.port}";
      in
      lib.mkDefault
        "${config.scheme}://${config.host}${port}${config.path}";
  };

  downstreamOptions = { name, config, ... }@inputs: {
    options = {
      implementation = lib.mkOption {
        type = types.enum [ "nginx" "cloudflared" ];
        default = "nginx";
        description = lib.mdDoc ''
          This option determines the implementation of the reverse proxy.
        '';
      };
      host = lib.mkOption {
        type = types.str;
        default = "localhost";
        description = lib.mdDoc ''
          This is the host(name) used as a base.
        '';
      };
      path = lib.mkOption {
        type = types.str;
        default = "/";
        description = lib.mdDoc ''
          This is the path under which the upstreams are placed.
        '';
      };

      default = lib.mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Wether to add upstreams to this downstream by default.
        '';
      };

      upstreams = lib.mkOption {
        type = types.attrsOf (types.submodule upstreamOptions);
        description = lib.mdDoc ''
          Attrset of all the upstreams for this downstream.
        '';
      };

      nginxOptions = lib.mkOption {
        type = options.services.nginx.virtualHosts.type.nestedTypes.elemType;
        default = { };
        description = lib.mdDoc ''
          Extra options for this virtualHost.
        '';
      };

      virtualHosts = lib.mkOption {
        type = options.services.nginx.virtualHosts.type;
        default = { };
        description = lib.mdDoc ''
          The virtualHosts belonging to this downstream.
        '';
      };

      cloudflaredTunnelID = lib.mkOption {
        type = types.str;
        description = lib.mdDoc ''
          UUID of the tunnel for this downstream.
        '';
      };
      cloudflaredCredentialsFile = lib.mkOption {
        type = types.str;
        description = lib.mdDoc ''
          Location of the credentials file for this tunnel.
        '';
      };
      tunnelOptions = lib.mkOption {
        type = options.services.cloudflared.tunnels.type.nestedTypes.elemType;
        default = { };
        description = lib.mdDoc ''
          Extra options for this tunnel.
        '';
      };
    };

    config.upstreams = lib.mkDefault (
      lib.filterAttrs
        (n: v: builtins.elem name v.downstreams)
        cfg.upstreams);

    config.virtualHosts =
      let
        mkVirtualHosts = lib.mapAttrsToList mkVirtualHost config.upstreams;
        mkVirtualHost = upstreamName: upstream: {
          "${upstreamName}.${config.host}" = lib.mkMerge ([
            {
              locations.${config.path} = {
                proxyWebsockets = true;
                proxyPass = upstream.url;
              };
            }
          ] ++ inputs.options.nginxOptions.definitions);
        };
      in
      lib.mkMerge mkVirtualHosts;
  };
in
{
  options.reverseProxy = {
    enable = lib.mkEnableOption "revese proxying";

    upstreams = lib.mkOption {
      type = types.attrsOf (types.submodule upstreamOptions);
      description = lib.mdDoc ''
        List of upstream services to proxy to.
      '';
    };

    downstreams = lib.mkOption {
      description = lib.mdDoc ''
        List of downstream configurations which will point to upstream services.
      '';
      type = types.attrsOf (types.submodule downstreamOptions);
    };
  };

  config =
    let
      downstreamsFor = implementation:
        (builtins.filter
          (d: d.implementation == implementation)
          (builtins.attrValues cfg.downstreams));
    in
    lib.mkIf cfg.enable {
      services.nginx =
        let
          nginxDownstreams = downstreamsFor "nginx";
        in
        {
          enable = lib.mkDefault nginxDownstreams != [ ];
          virtualHosts = lib.mkMerge (lib.flatten
            (builtins.map (d: d.virtualHosts) nginxDownstreams));
        };

      services.cloudflared =
        let
          cloudflaredDownstreams = (downstreamsFor "cloudflared");
          mkTunnel = downstream: {
            ${downstream.cloudflaredTunnelID} = lib.mkMerge [
              {
                credentialsFile = downstream.cloudflaredCredentialsFile;
                default = lib.mkDefault "http_status:404";
                ingress =
                  let
                    mkIngress = upstreamName: upstream: {
                      "${upstreamName}.${downstream.host}" = {
                        service = upstream.url;
                      };
                    };
                  in
                  lib.mkMerge (lib.mapAttrsToList mkIngress downstream.upstreams);
              }
              (lib.mkDefault downstream.tunnelOptions)
            ];
          };
        in
        {
          enable = lib.mkDefault cloudflaredDownstreams != [ ];
          tunnels = lib.mkMerge (builtins.map mkTunnel cloudflaredDownstreams);
        };
    };
}

