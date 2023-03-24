{ config, lib, pkgs, ... }:
let
  inherit (lib) fileContents;

in
{

  nix.package = pkgs.nixFlakes;

  imports = [
    ./nix.nix
    ./shell.nix

    ../../local/locale.nix
    ../../modules/neovim.nix
  ];


  security = {

    protectKernelImage = true;

  };

  services.earlyoom.enable = true;

  users.mutableUsers = false;

  environment.systemPackages = [ pkgs.neovim ];
  environment.variables.EDITOR = "nvim";

}
