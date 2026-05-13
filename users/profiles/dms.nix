{ pkgs, ... }:
{
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableDynamicTheming = false;
    niri.includes = {
      enable = true;
      filesToInclude = [
        "alttab"
        # "binds"
        # "colors"
        "layout"
        "outputs"
        "wpblur"
      ];
    };
  };

}
