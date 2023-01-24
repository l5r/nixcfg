{ lib, pkgs, ... }: {
  imports = [
    ./data.nix
    ./media.nix
    ./paths.nix
    ./fileshare.nix
    ./nginx.nix
  ];
}
