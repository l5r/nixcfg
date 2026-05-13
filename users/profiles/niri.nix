{ lib, pkgs, ... }:
let
  makeDesktopBind = i: {
    "Mod+${toString i}".action.focus-workspace = i;
    "Mod+Shift+${toString i}".action.move-window-to-workspace = i;
  };
  desktopBinds = lib.attrsets.mergeAttrsList (map makeDesktopBind (lib.lists.range 1 9));
in
{
  home.packages = [ pkgs.wireplumber ];
  programs.niri = {
    # enable = true;
    settings = {
      binds = desktopBinds // {
        "Mod+H".action.focus-column-or-monitor-left = [ ];
        "Mod+Shift+H".action.move-column-left-or-to-monitor-left = [ ];
        "Mod+J".action.focus-window-or-monitor-down = [ ];
        "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [ ];
        "Mod+K".action.focus-window-or-monitor-up = [ ];
        "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [ ];
        "Mod+L".action.focus-column-or-monitor-right = [ ];
        "Mod+Shift+L".action.move-column-right-or-to-monitor-right = [ ];

        "Mod+T".action.toggle-column-tabbed-display = [ ];
        "Mod+F".action.fullscreen-window = [ ];
        "Mod+Shift+Q".action.close-window = [ ];
        "Mod+Equal".action.set-column-width = [ "+10%" ];
        "Mod+Minus".action.set-column-width = [ "-10%" ];

        "Mod+Shift+slash".action.show-hotkey-overlay = [ ];
        "Mod+Return".action.spawn = [ "kitty" ];
        "Mod+Space".action.spawn = [
          "dms"
          "ipc"
          "spotlight"
          "open"
        ];

        "XF86AudioRaiseVolume".action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.1+"
        ];
        "XF86AudioLowerVolume".action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.1-"
        ];
        "XF86MonBrightnessDown".action.spawn = [
          "${pkgs.brightnessctl}/bin/brightnessctl"
          "set"
          "5%-"
        ];
        "XF86MonBrightnessUp".action.spawn = [
          "${pkgs.brightnessctl}/bin/brightnessctl"
          "set"
          "5%+"
        ];
        "XF86AudioPlay".action.spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "play-pause"
        ];
        "XF86AudioNext".action.spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "next"
        ];
        "XF86AudioPrev".action.spawn = [
          "${pkgs.playerctl}/bin/playerctl"
          "previous"
        ];
      };
      input = {
        focus-follows-mouse.enable = true;
        keyboard = {
          numlock = true;
          xkb.options = "ctrl:nocaps";
        };
        touchpad = {
          click-method = "clickfinger";
          tap = false;
        };
      };
    };
  };
}
