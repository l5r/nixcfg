{ config, pkgs, lib, ...}:
let secrets = import ../../secrets; in
{

  services.spotifyd = {
    enable = true;
    package = pkgs.spotifyd.override {
      withPulseAudio = true;
      withKeyring = true;
      withMpris = true;
    };
    settings = {
      global = secrets.spotify;
    };
  };


  home.packages = [ pkgs.spotify-tui ];

  xdg.configFile."spotify-tui/config.yml".text = lib.generators.toYAML {} {
    theme = {
      text = "DarkGray";
      header = "Black";
    };
  };
}
