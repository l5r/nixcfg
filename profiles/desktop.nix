{ config, lib, pkgs, ... }:
{
  imports = [
    # ./core
    ./graphical
    ./networking
    ./games.nix

    ../modules/rootless.nix
  ];

}
