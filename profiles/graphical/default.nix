{ config, lib, pkgs, ... }:
{
  imports = [
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/sway.nix
    ./greetd.nix
  ];
}
