{ lib, pkgs, ... }: {
  imports = [ ./media.nix ./fileshare.nix ./nginx.nix ];
}
