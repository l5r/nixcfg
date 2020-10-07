{ config, pkgs, ... }: {
  programs.waybar = {
    settings = [

      # Main bar
      {
        layer = "top";
        modules-left = ["sway/workspaces" "sway/mode"];
        modules-center = ["sway/window"];
        modules-right = ["tray" "pulseaudio" "idle_inhibitor" "battery" "clock"];
        "sway/window" = {
          max-length = 50;
        };
        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };
        clock = {
          format-alt = "{:%F %H:%M}";
        };
      }

    ];

    systemd.enable = true;

  };

  xdg.configFile."waybar/style.css".source = ./waybar.css;

}
