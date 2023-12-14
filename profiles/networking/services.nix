{ config, pkgs, ... }:
let
  secrets = import ../../secrets;
in
{

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

  programs.mosh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    # SSH
    22
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
    nssmdns = true;
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
