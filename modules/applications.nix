{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [

    # system utilities
    file-roller
    pantheon.pantheon-agent-polkit
    gnome-usage
    xdg-utils

    # applications
    pantheon.elementary-photos
    pantheon.elementary-videos
    pantheon.elementary-music
    pantheon.elementary-calculator
    pantheon.elementary-calendar
    libreoffice

    # spotify
    # teams
    # discord
    # slack
    # zoom-us

    eid-mw

    # configuration
    # pantheon.elementary-settings-daemon
    (
      pantheon.switchboard-with-plugs.override {
        useDefaultPlugs = true;
        plugs = [
          pantheon.switchboard-plug-bluetooth
          pantheon.switchboard-plug-network
          pantheon.switchboard-plug-onlineaccounts
          pantheon.switchboard-plug-printers
          pantheon.switchboard-plug-security-privacy
          pantheon.switchboard-plug-sharing
          pantheon.switchboard-plug-sound
          #glib-networking
        ];

      }
    )
  ];
}
