{ config, pkgs, ... }: {

  imports = [ ./printing.nix ./services.nix ];

  networking.networkmanager.enable = true;
  networking.nameservers = [ "2606:4700:4700::1111" "2606:4700:4700::1001" "1.1.1.1" "1.0.0.1" ];

}
