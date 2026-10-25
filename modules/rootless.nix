{ config, lib, pkgs, ... }:
let
  defaultDataPaths = lib.mkMerge [
    (
      lib.mkIf config.networking.networkmanager.enable
        [ "/etc/NetworkManager/system-connections" ]
    )
    (
      lib.mkIf config.hardware.bluetooth.enable
        [ "/var/lib/bluetooth" ]
    )
    (
      lib.mkIf config.virtualisation.docker.enable
        [ "/var/lib/docker" ]
    )
    (
      lib.mkIf config.services.zerotierone.enable
        [ "/var/lib/zerotier-one" ]
    )
    [
      {
        directory = "/var/lib/nixos";
        user = "root";
        group = "root";
        mode = "0750";
      }
    ]
  ];
  cfg = config.rootless;
in
{

  imports = [ ./link.nix ];

  options = {
    rootless = {
      enable = lib.mkEnableOption "rootless system";
      persistDir = lib.mkOption {
        example = "/my/permanent/directory";
        default = "/persist";
        type = lib.types.path;
      };

      dataPaths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
      };

      zfsPart = lib.mkOption {
        type = lib.types.str;
        default = "rpool/secure/root";
      };

      defaultDataPaths = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config =
    let
      dataPaths = lib.mkMerge (
        [ cfg.dataPaths ] ++ [ (lib.mkIf cfg.defaultDataPaths defaultDataPaths) ]
      );
    in
    lib.mkIf cfg.enable {

      environment.persistence.${cfg.persistDir}.directories = dataPaths;

      fileSystems."/" = {
        fsType = "zfs";
        device = cfg.zfsPart;
      };


      boot.initrd.systemd = {
        enable = true;
        services.initrd-rollback-root = {
          after = [ "zfs-import-rpool.service" ];
          wantedBy = [ "initrd.target" ];
          before = [
            "sysroot.mount"
          ];
          path = [ pkgs.zfs ];
          description = "Rollback root fs";
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = "zfs rollback -r ${cfg.zfsPart}@blank";
        };
      };
    };
}
