{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./audio.nix
    ./sway.nix
    ./greetd.nix
  ];
}
