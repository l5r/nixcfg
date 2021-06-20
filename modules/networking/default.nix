{ config, pkgs, ... }: {

  imports = [ ./nas.nix ./printing.nix ./services.nix ];

  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

}
