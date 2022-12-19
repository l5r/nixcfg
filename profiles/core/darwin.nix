{ config, lib, pkgs, inputs, ... }:
let
  pkgs-x86_64 = import inputs.nixpkgs { localSystem = "x86_64-darwin"; };
in
{

  nix.package = pkgs.nix;

  imports = [
    ./nix.nix
    ./shell.nix

    # inputs.home

    # ../../modules/neovim.nix
  ];

  environment.systemPackages = [
    pkgs.neovim
  ];

  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # nixpkgs.overlays = [
  #   (self: super: {
  #    inherit (pkgs-x86_64) haskell haskellPackages pandoc httpie;
  #   })
  # ];

}
