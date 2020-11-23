{ config, pkgs, ...}: {

  programs.kitty = {
    enable = true;

    font = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };

    keybindings = {
      "ctrl+shift+n" = "new_os_window_with_cwd";
    };

    settings = (import ./colors.nix) // {
      tab_bar_style = "powerline";
    };
  };
}
