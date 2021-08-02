{ config, lib, pkgs, ... }:
{
  imports = [
    # ./core
    ./graphical
    ./networking

    ../modules/rootless.nix
  ];

  services.tlp.enable = true;

}
