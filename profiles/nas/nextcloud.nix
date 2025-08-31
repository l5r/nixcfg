{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;
in
{
  reverseProxy.upstreams.nextcloud = {
    url = "http://127.0.0.1";
    downstreams = [ "external" ];
  };
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.${secrets.virtualHostnames.external.hostname}";
    https = true;
    package = pkgs.nextcloud29;

    home = "${config.my.paths.systemData}/var/lib/nextcloud";

    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "${pkgs.writeText "adminpass" "0704EFC6-77E8-40C4-89D2-F157DB1C7F2E"}";
    };

    extraAppsEnable = true;
    extraApps = with pkgs.nextcloud28Packages.apps;{
      inherit bookmarks calendar contacts deck
        groupfolders mail notes polls spreed tasks;
    };

    caching.redis = true;
    caching.apcu = true;
    settings = {
      redis = {
        host = "/run/redis-nextcloud/redis.sock";
        port = 0;
        dbindex = 0;
        timeout = 1.5;
      };
      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";

      default_language = "nl";
      default_locale = "nl_BE";
      default_phone_region = "BE";

      lost_password_link = "disabled";
      #"simpleSignUpLink.shown" = false;

      log_type = "syslog";
      logtimezone = "Europe/Brussels";

      preview_libreoffice_path = "${pkgs.libreoffice}/bin/libreoffice";
      preview_ffmpeg_path = "${pkgs.ffmpeg}/bin/ffmpeg";

      trusted_proxies = [ "127.0.0.1" "::1" ];
    };
    phpOptions = {
      "redis.session.locking_enabled" = "1";
      "redis.session.lock_retries" = "-1";
      "redis.session.lock_wait_time" = "10000";
      "opcache.interned_strings_buffer" = "16";
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    addSSL = true;
    useACMEHost = "external";
  };

  services.postgresql = {
    enable = true;
    dataDir = "${config.my.paths.systemData}/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" "redis-nextcloud.service" ];
    after = [ "postgresql.service" "redis-nextcloud.service" ];
  };

  services.redis.servers.nextcloud = {
    enable = true;
    settings = {
      maxmemory = "100mb";
      maxmemory-policy = "allkeys-lru";
    };
  };

  users.users.nextcloud.extraGroups = [ "redis-nextcloud" "data" ];
  users.users.postgres.extraGroups = [ "data" ];
  users.groups.nextcloud.members = [ "data" ];
}
