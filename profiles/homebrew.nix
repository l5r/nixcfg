{ config, pkgs, lib, ... }: {
  homebrew = {
    enable = true;
    cleanup = "uninstall";
    brewPrefix = "/opt/homebrew/bin";

    casks = [
      # "bitwarden"
      "betterdummy"
      "discord"
      "firefox"
      "google-drive"
      "libreoffice"
      "microsoft-office"
      "microsoft-teams"
      "musicbrainz-picard"
      "nextcloud"
      # "openzfs"
      "playonmac"
      "remarkable"
      "spotify"
      "steam"
      "vimr"
      "vlc"
      "webtorrent"
      "zoom"
    ];

    masApps = {
      bitwarden = 1352778147;
      messenger = 1480068668;
    };
  };
}
