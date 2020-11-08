{ config, lib, pkgs, ... }:
let
  defaultDataPaths = lib.mkMerge [
    (lib.mkIf config.networking.networkmanager.enable
    [ "/etc/NetworkManager/system-connections" ])
    (lib.mkIf config.hardware.bluetooth.enable
    [ "/var/lib/bluetooth" ])
    (lib.mkIf config.virtualisation.docker.enable 
    [ "/var/lib/docker" ])
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
          default = [];
        };

        defaultDataPaths = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };

    config = let
      dataPaths = lib.mkMerge (
        [ cfg.dataPaths ] ++ [ (lib.mkIf cfg.defaultDataPaths defaultDataPaths) ]
      );
    in
    lib.mkIf cfg.enable {

        link = {
          enable = true;
          farms = [ {
            dir = cfg.persistDir;
            paths = dataPaths;
          } ];
        };

        fileSystems."/" = {
          fsType = "tmpfs";
          device = "none";
        };

      };
    }
