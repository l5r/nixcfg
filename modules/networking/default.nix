
{ config, pkgs, ...}: {

  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

}

