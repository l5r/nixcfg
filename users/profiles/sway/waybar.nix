{ lib, config, pkgs, ... }: {
  programs.waybar = {
    enable = true;

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
        pulseaudio = {
          "format" = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon}";
          "format-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "phone-muted" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" ""];
          };
          "scroll-step" = 1;
          "on-click" = "pavucontrol";
          "ignored-sinks" = ["Easy Effects Sink"];
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
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
    systemd.target = "sway-session.target";
    style = lib.readFile ./waybar.css;

  };

  # xdg.configFile."waybar/style.css".source = ./waybar.css;

}
