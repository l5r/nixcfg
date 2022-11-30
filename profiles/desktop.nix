{ config, lib, pkgs, ... }:
{
  imports = [
    ./core
    ./graphical
    ./networking
    ./games.nix
    ./eid.nix

    ../modules/rootless.nix
  ];
}
