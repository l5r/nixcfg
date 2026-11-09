{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./audio.nix
    # ./sway.nix
    ./niri.nix
    # ./greetd.nix
  ];

  programs.dms-greeter = {
      enable = true;
      compositor.name = "niri";
  };

  programs.dank-material-shell.enable = true;
}
