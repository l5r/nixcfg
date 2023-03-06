{ lib, config, pkgs, ... }:
let
  cfg = config.services.nocodb;
  inherit (lib) types;
in
{
  options = {
    services.nocodb = {
      enable = lib.mkEnableOption "nocodb";

      homeDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/nocodb";
        description = lib.mdDoc ''
          The home directory for nocodb
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "nocodb";
        description = ''
          User account under which nocodb runs.
        '';
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "nocodb";
        description = ''
          Group under which nocodb runs.
        '';
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = lib.mdDoc ''
          File containing environment vars for the nocodb service.

          For production usecases, it is recommended to configure

          * `NC_DB`,
          * `NC_AUTH_JWT_SECRET`,
          * `NC_PUBLIC_URL`,
          * `NC_REDIS_URL`
        '';
      };
      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = null;
        description = lib.mdDoc ''
          Environment vars for the nocodb service.

          For production usecases, it is recommended to configure

          * `NC_DB`,
          * `NC_AUTH_JWT_SECRET`,
          * `NC_PUBLIC_URL`,
          * `NC_REDIS_URL`
        '';
      };

      port = lib.mkOption {
        type = types.port;
        default = 8080;
        description = ''
          NocoDB port
        '';
      };
      openFirewall = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for NocoDB
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.homeDir}' 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.nocodb = {
      description = "NocoDB - Open Source Airtable Alternative";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        WorkingDirectory = cfg.homeDir;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.nocodb}/bin/nocodb";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };

      environment = {
        PORT = builtins.toString cfg.port;
      } // cfg.environment;

    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users = {
      users = lib.mkIf (cfg.user == "nocodb") {
        nocodb = {
          group = cfg.group;
          home = cfg.homeDir;
          isSystemUser = true;
        };
      };
      groups = lib.mkIf (cfg.group == "nocodb") {
        nocodb = { };
      };
    };
  };
}
