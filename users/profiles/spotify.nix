{ config, pkgs, lib, ... }:
let
  secrets = import ../../secrets;
in
{

  services.spotifyd = {
    enable = true;
    package = pkgs.spotifyd.override {
      withPulseAudio = true;
      withKeyring = true;
      withMpris = true;
    };
    settings = {
      global = {
        backend = "pulseaudio";
      } // secrets.spotify;
    };
  };

}
