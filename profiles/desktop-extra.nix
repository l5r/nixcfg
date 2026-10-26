{ config, pkgs, ... }:
{
  imports = [
    ./games.nix
    ./desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    pantheon.elementary-calendar
    libreoffice
    pantheon.elementary-photos
    pantheon.elementary-videos
    pantheon.elementary-music

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
        ];

      }
    )
  ];

  fonts = {
    packages = with pkgs; [
      corefonts
      vista-fonts

      google-fonts
    ];
  };
}
