{ config, lib, pkgs, ... }:
let
  inherit (lib) fileContents;

in
{

  nix.package = pkgs.nixVersions.stable;

  imports = [
    ./nix.nix
    ./shell.nix

    ../../local/locale.nix
    # ../../modules/neovim.nix
  ];


  security = {

    protectKernelImage = true;

  };

  services.earlyoom.enable = true;

  users.mutableUsers = false;

  environment.systemPackages = [ pkgs.helix pkgs.nil ];
  environment.variables.EDITOR = "hx";

}
