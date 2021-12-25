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

  fonts = {
    fonts = with pkgs; [ fira-code font-awesome aileron dejavu_fonts ];

    fontconfig.defaultFonts = {

      monospace = [ "Fira Code Nerd Font" ];

      sansSerif = [ "Aileron" ];

    };
  };

  security = {

    protectKernelImage = true;

  };

  services.earlyoom.enable = true;

  users.mutableUsers = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.autoOptimiseStore = true;

}
