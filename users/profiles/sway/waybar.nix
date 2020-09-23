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

  style = ''
    * {
      border: none;
      border-radius: 0;
      /* `otf-font-awesome` is required to be installed for icons */
      font-family: Roboto, Helvetica, Arial, sans-serif;
      font-size: 13px;
      min-height: 0;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #idle_inhibitor,
    #mpd {
      margin: 0 1rem;
    }

    #workspaces button.focused,
    #workspaces button.urgent {
      font-style: bold;
    }

    #workspaces button.urgent {
      color: #ee2222
    };
  '';
  systemd.enable = true;
  };

}
