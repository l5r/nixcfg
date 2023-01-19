{ lib, pkgs, ... }: {
  imports = [
    ./data.nix
    ./media.nix
    ./fileshare.nix
    ./nginx.nix
  ];
}
