{ config, pkgs, ... }: {

  programs = {
    evince.enable = true;
    nm-applet.enable = true;
  };

  environment.systemPackages = with pkgs; [
    (
      firefox-devedition-bin.override {
        forceWayland = true;
        pkcs11Modules = [ pkgs.eid-mw ];
      }
    )
    kitty
    lxtask
    pantheon.elementary-files
    pantheon.elementary-gtk-theme
    pantheon.pantheon-agent-polkit
    glib
    gvfs
    nfs-utils
    sshfs

    # cosmetic
    hicolor-icon-theme
    pantheon.elementary-icon-theme
    gnome3.adwaita-icon-theme
    elementary-xfce-icon-theme
    pantheon.extra-elementary-contracts
  ];

  programs.dconf.enable = true;
  services.gnome = {
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
    core-os-services.enable = true;
  };
  services.gvfs.enable = true;
  services.pantheon.contractor.enable = true;
  services.gsignond = {
    enable = true;
    plugins = with pkgs; [
      gsignondPlugins.mail
      gsignondPlugins.oauth
    ];
  };

}
