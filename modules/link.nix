{ config, lib, pkgs, ... }:
let
  cfg = config.link;
in
  {

    options = {
      link = {
        enable = lib.mkEnableOption "link farms";
        farms = lib.mkOption {
          description = "System symlinks";

          type = with lib.types; listOf (submodule {
            options = {

              dir = lib.mkOption {
                example = /my/permanent/directory;
                type = path;
              };

              paths = lib.mkOption {
                type = listOf path;
              };
            };
          });
        };
      };
    };

    config = lib.mkIf cfg.enable
    (let
      paths = lib.flatten (map
      (farm: map
      (path: { dir = farm.dir; path = path; })
      farm.paths)
      cfg.farms);
    in
    {
      environment.etc = lib.mkMerge (map ({ dir, path }:
      lib.mkIf (lib.hasPrefix "/etc" path) {
        "${lib.removePrefix "/etc" path}" = {
          source = "${dir}${path}";
        };
      }) paths);

      systemd.tmpfiles.rules = lib.mkMerge (map ({ dir, path }:
      lib.mkIf (!lib.hasPrefix "/etc" path) [
        "L ${path} - - - - ${dir}${path}"
      ]) paths);

      system.activationScripts.ensureLinkedDirs = lib.concatMapStrings ({ dir, path }:
      "mkdir -p ${dir}${path}\n"
      ) paths;

    });
  }

