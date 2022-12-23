{ config, lib, pkgs, ... }:
{
  imports = [
    ./core
    ./graphical
    ./networking
    ./networking/nas.nix
    ./games.nix
    ./eid.nix

    ../modules/rootless.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
