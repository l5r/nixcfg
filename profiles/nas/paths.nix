{ lib, pkgs, config, ... }:
{
  imports = [ ../../modules/paths.nix ];
  my.paths = rec {
    media = "/media/naspool1/media";
    mediaData = "${media}/.local";
    data = "/media/naspool1/data";
    music = "/media/naspool1/media/Music";
  };
}
