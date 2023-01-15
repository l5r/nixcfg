{ lib, config, pkgs, ... }:
let
  cfg = config.services.slskd;
  configFormat = pkgs.formats.yaml { };
  configFile = configFormat.generate "slskd.yml" cfg.config;
in
{
  options = {
    services.slskd = {
      enable = lib.mkEnableOption "slskd daemon";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.slskd;
        description = ''
          The slskd package to use.
        '';
      };
      appDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/slskd";
        description = lib.mdDoc ''
          The [application directory](https://github.com/slskd/slskd/blob/master/docs/config.md#application-directory-configuration) for slskd.
        '';
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "slskd";
        description = ''
          User account under which slskd runs.
        '';
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "slskd";
        description = ''
          Group under which slskd runs.
        '';
      };
      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          File containing environment vars for the slskd service.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Open ports in the firewall for slskd.
        '';
      };

      httpPort = lib.mkOption {
        type = lib.types.port;
        default = 5000;
        description = ''
          Port for the web interface
        '';
      };
      httpsPort = lib.mkOption {
        type = lib.types.port;
        default = 5001;
        description = ''
          Port for the web interface over HTTPS
        '';
      };

      soulseekPort = lib.mkOption {
        type = lib.types.port;
        default = 50000;
        description = ''
          Port to listen for soulseek connections.
        '';
      };

      config = lib.mkOption {
        type = configFormat.type;
        default = { };
        description = lib.mdDoc ''
          `slskd` configuration options.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.appDir}' 0700 ${cfg.user} ${cfg.group} - -"
      # Not strictly necessary, but may be useful
      "L+ '${cfg.appDir}/slskd.yml' 0700 ${cfg.user} ${cfg.group} - - '${configFile}'"
    ];

    systemd.services.slskd = {
      description = "slskd";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/slskd --app-dir '${cfg.appDir}' --config '${configFile}'";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };

      environment = {
        SLSKD_HTTP_PORT = builtins.toString cfg.httpPort;
        SLSKD_HTTPS_PORT = builtins.toString cfg.httpsPort;
        SLSKD_SLSK_LISTEN_PORT = builtins.toString cfg.soulseekPort;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.httpPort cfg.httpsPort cfg.soulseekPort ];
    };

    users = {
      users = lib.mkIf (cfg.user == "slskd") {
        slskd = {
          group = cfg.group;
          isSystemUser = true;
        };
      };
      groups = lib.mkIf (cfg.group == "slskd") {
        slskd = { };
      };
    };
  };
}
