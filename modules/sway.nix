
{ config, pkgs, lib, ... }: 
let
  startsway = (pkgs.writeTextFile {
    name = "startsway";
    destination = "/bin/startsway";
    executable = true;
    text = ''#! ${pkgs.bash}/bin/bash

      # first import environment variables from the login manager
      systemctl --user import-environment
      # then start the service
      exec systemctl --user start sway.service
    '';
  });
in
{
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock-fancy # lockscreen
      swayidle
      xwayland # for legacy apps
      waybar # status bar
      mako # notification daemon
      kanshi # autorandr
      wofi
      wl-clipboard
      # wlogout
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };

  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
  };
  location.provider = "geoclue2";
  services.geoclue2 = {
    enable = true;
  };

  programs.waybar.enable = true;

  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "sway.service" ];
    partOf = [ "sway-session.target" ];
    serviceConfig = {
      # kanshi doesn't have an option to specifiy config file yet, so it looks
      # at .config/kanshi/config
      ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };
}

