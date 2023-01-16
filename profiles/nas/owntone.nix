{ lib, pkgs, ... }: {
  imports = [ ../../modules/owntone.nix ];
  services.owntone = {
    enable = true;
    cacheDir = "/persist/var/cache/owntone";
    group = "media";
    openFirewall = true;
    extraConfig = ''
      library {
        name = "Leander"
        directories = {
          "/media/naspool1/media/Music",
          "/media/naspool1/media/Movies",
          "/media/naspool1/media/TV"
        }
        filepath_ignore = { "^\\.", "/\\." }
      }
    '';
  };
}
