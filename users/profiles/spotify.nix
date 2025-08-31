{ config, pkgs, lib, ... }:
let
  secrets = import ../../secrets;
in
{

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "pulseaudio";
      } // secrets.spotify;
    };
  };

}
