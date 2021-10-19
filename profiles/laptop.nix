{ config, lib, pkgs, ... }:
{
  imports = [
    # ./core
    ./graphical
    ./networking

    ../modules/rootless.nix
  ];

}
