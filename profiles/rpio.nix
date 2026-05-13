{ config, lib, pkgs, modulesPath, ... }: {
  environment.systemPackages = [
    pkgs.rpio-tools
  ];

  virtualisation.docker.enable = true;

  systemd.user.services.rocketchat = {
    wantedBy = ["graphical-session.target"];
    partOf   = ["graphical-session.target"];
    script = ''
      #!/bin/sh
      ${pkgs.rocketchat-desktop}/bin/rocketchat-desktop
    '';
  };
}
