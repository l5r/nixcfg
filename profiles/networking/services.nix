{ config, pkgs, ... }:
let
  secrets = import ../../secrets;
in
{

  imports = [./ssh.nix];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
  ];
  networking.firewall.allowedUDPPorts = [
    # Avahi
    5353
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.avahi = {
    enable = true;
    ipv6 = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = secrets.zerotierone.joinNetworks;
  };

  networking.hosts = {
    "${secrets.ips.storig}" = [ "storig" "storig.local" "*.storig" "*.storig.local" ];
  };

}
