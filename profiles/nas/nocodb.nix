{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;
  dataDir = config.my.paths.data;
in
{
  imports = [ ../../modules/nocodb.nix ];

  reverseProxy.upstreams.nocodb = {
    port = config.services.nocodb.port;
    path = "";
    downstreams = [ "internal" "external" ];
  };

  age.secrets.nocodb-environment = {
    file = ../../secrets/nocodb-environment.age;
    mode = "0400";
    owner = "nocodb";
    group = "wheel";
  };

  services.nocodb = {
    enable = true;
    port = 2080;
    group = "data";

    homeDir = "${config.my.paths.systemData}/var/lib/nocodb";

    environmentFile = config.age.secrets.nocodb-environment.path;
    environment = {
      NC_PUBLIC_URL = "nocodb.${secrets.virtualHostnames.external.hostname}";
      NC_REDIS_URL = "redis-socket:///run/redis-nocodb/redis.sock";
      NC_DISABLE_TELE = "true";
      HOST = "localhost";
    };
  };

  services.nginx.virtualHosts.${config.services.nocodb.environment.HOST} = {
    addSSL = true;
    useACMEHost = "external";
  };

  services.postgresql = {
    enable = true;
    dataDir = "${config.my.paths.systemData}/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureDatabases = [ "nocodb" ];
    ensureUsers = [{
      name = "nocodb";
      ensurePermissions."DATABASE nocodb" = "ALL PRIVILEGES";
    }];
  };

  services.redis.servers.nocodb = {
    enable = true;
    settings = {
      maxmemory = "100mb";
      maxmemory-policy = "allkeys-lru";
    };
  };

  users.users.nocodb.extraGroups = [ "redis-nocodb" ];
}
