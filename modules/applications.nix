{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [

    # system utilities
    file-roller
    xdg-utils

    # applications
    pantheon.elementary-calculator

    eid-mw
  ];
}
