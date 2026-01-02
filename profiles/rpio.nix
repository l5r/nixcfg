{ config, lib, pkgs, modulesPath, ... }: {
  environment.systemPackages = [
    pkgs.rpio-tools
  ]; 

  virtualisation.docker.enable = true;
}
