{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./audio.nix
    ./sway.nix
    ./niri.nix
    # ./greetd.nix
  ];

  programs.dank-material-shell = {
    greeter = {
      enable = true;
      compositor.name = "niri";
    };
  };
}
