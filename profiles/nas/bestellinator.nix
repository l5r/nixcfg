{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;
  dataDir = config.my.paths.data;
  systemDataDir = config.my.paths.systemData;
  appDir = "${systemDataDir}/var/lib/bestellinator";
  socket = "unix://run/bestellinator.sock";
  bestellinator = pkgs.bestellinator;
in
{
  systemd.tmpfiles.rules = [
    "d ${appDir} 0700 bestellinator bestellinator"
  ];

  reverseProxy.upstreams.bestellinator = {
    url = socket;
    downstreams = [ "external" ];
  };

  age.secrets.bestellinator-environment = {
    file = ../../secrets/bestellinator-environment.age;
    mode = "0400";
    owner = "bestellinator";
    group = "bestellinator";
  };

  systemd.services.bestellinator-setup = {
    requiredBy = [ "bestellinator.service" ];
    before = [ "bestellinator.service" ];
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];

    description = "Prepare Bestellinator DB";
    environment = config.systemd.services.bestellinator.environment;

    unitConfig = {
      WorkingDirectory = appDir;
    };

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bestellinator}/bin/bestellinator-rake db:prepare";
      User = "bestellinator";
      Group = "bestellinator";
      EnvironmentFile = config.age.secrets.bestellinator-environment.path;
    };
  };

  systemd.services.bestellinator = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    requires = [ "network.target" "postgresql.service" "bestellinator.socket" ];

    description = "Bestellinator";

    environment = {
      RAILS_SERVE_STATIC_FILES = "1";
      RAILS_ACTIVE_STORAGE_UPLOADS = "${appDir}/storage";
      RAILS_LOG_TO_STDOUT = "1";
      DATABASE_URL = "postgresql://bestellinator?host=/run/postgresql";
    };

    unitConfig = {
      WorkingDirectory = appDir;
    };

    serviceConfig = {
      Type = "simple";
      User = "bestellinator";
      Group = "bestellinator";
      WatchDogsec = 15;
      ExecStart = "${bestellinator}/bin/bestellinator-puma -b ${socket} -e production";
      EnvironmentFile = config.age.secrets.bestellinator-environment.path;
      Restart = "always";
    };
  };

  systemd.sockets.bestellinator = {
    wantedBy = [ "sockets.target" ];
    description = "Bestellinator";
    socketConfig = {
      ListenStream = "/run/bestellinator.sock";
      SocketUser = "bestellinator";
      SocketGroup = "bestellinator";
      SocketMode = "0660";

      # Socket options matching Puma defaults
      NoDelay = true;
      ReusePort = true;
      Backlog = 1024;
    };
  };

  services.postgresql = {
    enable = true;
    dataDir = "${config.my.paths.systemData}/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureDatabases = [ "bestellinator" ];
    ensureUsers = [{
      name = "bestellinator";
      ensurePermissions."DATABASE bestellinator" = "ALL PRIVILEGES";
    }];
  };

  users.users.postgres.extraGroups = [ "data" ];
  users.users.bestellinator = {
    group = "bestellinator";
    home = appDir;
    isSystemUser = true;
  };

  users.groups.bestellinator = { };

  users.users.cloudflared.extraGroups = [ "bestellinator" ];
}

