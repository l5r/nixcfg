{ lib, pkgs, config, ... }:
let
  cfg = config.services.owntone;
  types = lib.types;

  configFile = pkgs.writeText "owntone.conf" ''
    general {
      uid = "${cfg.user}"

      websocket_port = ${builtins.toString cfg.websocketPort}

      db_path = "${cfg.cacheDir}/songs3.db"
      logfile = "/var/log/owntone.log"

      cache_path = "${cfg.cacheDir}/cache.db"
    }

    library {
      port = ${builtins.toString cfg.listenPort}
    }

    ${cfg.extraConfig}
  '';
in
{
  options.services.owntone = {
    enable = lib.mkEnableOption "Owntone server";

    package = lib.mkOption {
      type = types.package;
      default = pkgs.owntone;
      description = lib.mdDoc ''
        The owntone package to use.
      '';
    };

    cacheDir = lib.mkOption {
      type = types.str;
      default = "/var/cache/owntone";
      description = lib.mdDoc ''
        Base directory for storing cache databases.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "owntone";
      description = ''
        User account under which owntone runs.
      '';
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "owntone";
      description = ''
        Group under which owntone runs.
      '';
    };

    websocketPort = lib.mkOption {
      type = types.port;
      default = 3688;
      description = ''
        Port for owntone websocket connection
      '';
    };
    listenPort = lib.mkOption {
      type = types.port;
      default = 3689;
      description = ''
        Port for owntone web interface
      '';
    };
    openFirewall = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open the firewall?
      '';
    };

    extraConfig = lib.mkOption {
      type = types.str;
      default = "";
      description = lib.mdDoc ''
        Extra configuration to append to owntone.conf
      '';
    };
  };


  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "f /var/log/owntone.log 0644 owntone media"
      "d ${cfg.cacheDir} 0755 owntone media"
    ];
    environment.systemPackages = [ cfg.package ];
    systemd.services.owntone = {
      description = "DAAP/DACP (iTunes), RSP and MPD server, supports AirPlay and Remote";
      documentation = [ "man:owntone(8)" ];

      requires = [ "network.target" "local-fs.target" "avahi-daemon.socket" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/owntone -f -c ${configFile}";
        MemoryMax = "256M";
        MemorySwapMax = "32M";

        Restart = "on-failure";
        RestartSec = 5;
        StartLimitBurst = 10;
        StartLimitInterval = 600;

        User = cfg.user;
        Group = cfg.group;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      users = lib.mkIf (cfg.user == "owntone") {
        owntone = {
          group = cfg.group;
          isSystemUser = true;
        };
      };
      groups = lib.mkIf (cfg.group == "owntone") {
        owntone = { };
      };
    };

    networking.firewall.allowedTCPPorts =
      lib.mkIf cfg.openFirewall [ cfg.listenPort cfg.websocketPort ];
  };
}

