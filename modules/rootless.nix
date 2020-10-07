{ config, lib, pkgs, ... }:
let
  defaultDataPaths = [
    # (lib.mkIf config.networking.networkmanager.enable
    "/etc/NetworkManager/system-connections"
    # (lib.mkIf config.hardware.bluetooth.enable
    "/var/lib/bluetooth"
  ];
  # cfg = config.rootless;
  cfg = { persistDir = "/persist"; };
in
  {

    # options = {
    #   rootless = {
    #     enable = lib.mkEnableOption "rootless system";
    #     persistDir = lib.mkOption {
    #       example = /my/permanent/directory;
    #       default = /persist;
    #       type = lib.types.path;
    #     };

    #     dataPaths = lib.mkOption {
    #       type = lib.types.listOf lib.types.path;
    #       default = [];
    #     };
    #   };
    # };

    config = let
      #dataPaths = cfg.dataPaths ++ defaultDataPaths;
      dataPaths = defaultDataPaths;
      paths = (lib.groupBy (path: if lib.hasPrefix "/etc" path then "etcPaths" else "otherPaths") dataPaths);
    in with paths;
    #lib.mkIf cfg.enable {
    {

      environment.etc = builtins.listToAttrs (map (path: {
        name = lib.removePrefix "/etc" path;
        value = {
          source = "${cfg.persistDir}/${path}";
        };
      }) etcPaths);

      systemd.tmpfiles.rules = map (path:
      "L ${path} - - - - ${cfg.persistDir}${path}"
      ) otherPaths;

      system.activationScripts.persist =
        lib.concatMapStrings (p: "mkdir -p ${cfg.persistDir}${p}\n") dataPaths;

        fileSystems."/" = {
          fsType = "tmpfs";
          device = "none";
        };

      };
    }
