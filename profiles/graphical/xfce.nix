{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.xorg.xinit ];
  services.xserver = {
    enable = true;
    autorun = false;
    enableCtrlAltBackspace = true;
    libinput.enable = true;
    desktopManager.xfce.enable = true;
    displayManager.startx.enable = true;
  };
}
