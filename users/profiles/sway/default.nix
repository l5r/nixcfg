{ config, pkgs, lib, ... }:
with rec {
  terminal = "${pkgs.kitty}/bin/kitty";
  commands = rec {
    terminalDialog = "${terminal} --class dialog -o remember_window_size=no -o initial_window_height=540 --";
    menu = "${pkgs.wofi}/bin/wofi -i -S drun,run";
    keyboardSwitcher = ''${terminalDialog} sh -c 'printf "0 us\n1 be" | ${pkgs.fzf}/bin/fzf | cut -d " " -f 1 | xargs ${pkgs.sway}/bin/swaymsg input type:keyboard xkb_switch_layout' '';
    windowSelect = pkgs.writeScriptBin "window-select" ''
      #!${pkgs.stdenv.shell}

        jq_query='.. | select(.type? =="workspace" and .num?) | .num as $num | .nodes | .. | select(.name? and .type == "con") | .num = $num | (.id | tostring) + "\t[" + (.num | tostring) + "] " + .name'
      
      ${pkgs.sway}/bin/swaymsg -t get_tree | \
        ${pkgs.jq}/bin/jq -r "$jq_query" | \
        ${pkgs.fzf}/bin/fzf --with-nth 2.. | \
        cut -f 1 | \
        xargs -i ${pkgs.sway}/bin/swaymsg [con_id={}] focus
    '';
    lock = "${pkgs.swaylock-fancy}/bin/swaylock-fancy";
    timer = "${pkgs.et}/bin/et 10:00";
    timerStatus = "${pkgs.et}/bin/et-status.sh";
  };
  rmdisp = pkgs.writeShellScriptBin "rmdisp" ''
    host=10.11.99.1
    if [ -n "$1" ]; then host=$1; fi

    output="$(swaymsg -t get_outputs --raw | ${pkgs.jq}/bin/jq '.[] | select(.make == "headless") | .name')"
    if [ -z "$output" ]; then swaymsg create_output; fi
    swaymsg output HEADLESS-1 scale 1.5
    swaymsg output HEADLESS-1 mode 1408x1872
    swaymsg output HEADLESS-1 enable

    nix run nixpkgs#wayvnc -- -o HEADLESS-1 localhost &
    sleep 1
    ssh "root@$host" -R 5900:localhost:5900 "systemctl stop xochitl && ./vnsee localhost; systemctl start xochitl"
    swaymsg output HEADLESS-1 disable
  '';
};
{
  imports = [ ./kanshi.nix ];
  home.packages = [
    commands.windowSelect
    rmdisp
  ];
  wayland.windowManager.sway = {
    enable = true;
    # Have NixOS install sway instead
    package = lib.mkForce null;
    extraConfig = ''
      set $laptop eDP-1
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
    '';
    config = {
      menu = commands.menu;
      # Logo key. Use Mod1 for Alt. Use Mod4 for ⌘.
      modifier = "Mod4";

      # Use Polybar instead
      bars = [];



      input = {
        "type:keyboard" = {
          xkb_options = "ctrl:nocaps";
          xkb_layout = "us,be";
          xkb_variant = ",";
          xkb_numlock = "enabled";
          xkb_capslock = "disabled";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
        };

        # Laptop touch screen
        "1267:9767:ELAN0732:00_04F3:2627" = {
          map_to_output = "eDP-1";
        };
      };

      # Keybindings
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+s" = "exec ${commands.menu}";
          "${modifier}+Ctrl+k" = "exec ${commands.keyboardSwitcher}";
          "${modifier}+w" = "exec ${commands.terminalDialog} ${commands.windowSelect}/bin/window-select";
          "${modifier}+t" = "layout toggle all";

          "${modifier}+bracketright" = "exec ${pkgs.mako}/bin/makoctl dismiss";
          "${modifier}+backslash" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";

          "${modifier}+bracketleft" = "exec ${commands.timer}";
          "${modifier}+apostrophe" = "exec ${commands.timerStatus}";

          # Media keys
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "Pause" = "exec ${commands.lock}";
          "Shift+Pause" = "exec systemctl suspend";
        };

      window.commands = [
        {
          criteria = { app_id = "dialog"; };
          command = "floating enable, border pixel 10, sticky enable";
        }
      ];

      startup = [
        {
          command = ''
            ${pkgs.swayidle}/bin/swayidle -w \
              timeout 300  '${commands.lock} &' \
              timeout 600  '${pkgs.sway}/bin/swaymsg "output * dpms off"; systemctl suspend'\
              resume       '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
              before-sleep 'loginctl lock-session $XDG_SESSION_ID' \
              lock         '${pkgs.playerctl}/bin/playerctl -a pause && lock'

          '';
        }
      ];
    };
  };
}
