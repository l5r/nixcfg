{ lib, pkgs, config, ... }:
let
  secrets = import ../../secrets;

  format = pkgs.formats.json { };
  seedFile = format.generate "portunus-seed.json" secrets.ldap.seed;
in
{
  services.portunus = {
    enable = true;
    port = 30001;
    stateDir = "/media/naspool1/data/System/var/lib/portunus";
    domain = secrets.virtualHostnames.internal.hostname;

    ldap = {
      suffix = secrets.ldap.suffix;
      searchUserName = "service";
      tls = true;
    };

    seedPath = seedFile;
  };
  systemd.services.portunus.environment.PORTUNUS_SERVER_HTTP_LISTEN =
    lib.mkForce "127.0.0.1:${builtins.toString config.services.portunus.port}";

  systemd.services.portunus.after = ["media-naspool1-data.mount"];
  systemd.services.portunus.requires = ["media-naspool1-data.mount"];

  reverseProxy.upstreams.portunus.port = config.services.portunus.port;

  age.secrets.ldap-service-password = {
    file = ../../secrets/ldap-service-password.age;
    mode = "0400";
    owner = "portunus";
    group = "portunus";
  };
}
