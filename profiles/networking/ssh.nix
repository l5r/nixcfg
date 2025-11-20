{ ... }: {
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
}
