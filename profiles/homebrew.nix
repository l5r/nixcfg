{ config, pkgs, lib, ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
    };
    # brewPrefix = "/opt/homebrew/bin";

    casks = [
      "bitwarden"
      # "betterdummy"
      # "discord"
      "firefox"
      "google-drive"
      "jellyfin-media-player"
      "libreoffice"
      "microsoft-office"
      # "microsoft-teams"
      # "nextcloud"
      "spotify"
      "steam"
      "vlc"
      "zerotier-one"
      # "zoom"
    ];

    masApps = {
      whatsapp = 310633997;
      remarkable = 1276493162;
      # bitwarden = 1352778147;
      # messenger = 1480068668;
    };
  };
}
