{ config, lib, pkgs, ... }:
{
  imports = [
    ./core
    ./graphical
    ./networking
    ./networking/nas.nix
    ./eid.nix

    ../modules/rootless.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
