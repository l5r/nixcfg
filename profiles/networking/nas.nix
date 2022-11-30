{ config, lib, pkgs, ... }:
let
  secrets = import ../../secrets;
  awsEnvVars = {
    AWS_ACCESS_KEY_ID = secrets.nas.s3AccessKeyID;
    AWS_SECRET_ACCESS_KEY = secrets.nas.s3SecretAccessKey;
  };
  nasFsOpts = {
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=${toString (60 * 30)}"
      "noauto"
      "nofail"
    ];
  };
in
{
  fileSystems = {

    # "/mnt/nas/backup" = nasFsOpts // {
    #   device = "[${secrets.nas.ip}]:/mnt/naspool1/backup";
    # };

    # "/mnt/nas/data" = nasFsOpts // {
    #   device = "[${secrets.nas.ip}]:/mnt/naspool1/data";
    # };

  };

  networking.hosts.${secrets.nas.ip} = [ secrets.nas.name ];

  # nix.binaryCaches = [ "s3://${secrets.nas.name}-nix-cache?endpoint=${secrets.nas.name}:9000" ];
  nix.binaryCachePublicKeys = [ (builtins.readFile ../../secrets/nix-cache-1.public.key) ];
  nix.extraOptions = ''
    secret-key-files = ${../../secrets/nix-cache-1.private.key}
  '';
  security.pki.certificateFiles = [ ../../secrets/NasCA.crt ];

  systemd.services.nix-daemon.environment = awsEnvVars;
  environment.sessionVariables = awsEnvVars;
}
