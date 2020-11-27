{ config, lib, pkgs, ... }:
{
  imports = [
    ../../modules/networking
    ../../modules/networking/services.nix
    ../../modules/networking/nas.nix
  ];
}
