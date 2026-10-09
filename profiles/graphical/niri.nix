{ pkgs, ... }: {
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = [
    pkgs.xwayland-satellite
  ];

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };
}
