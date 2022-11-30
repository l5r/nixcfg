{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ../../modules/audio.nix
    ./sway.nix
    ./greetd.nix
  ];
}
