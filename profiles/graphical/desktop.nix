{ config, pkgs, ... }:
let
  firefox =
    pkgs.firefox.override
      {
        pkcs11Modules = [ pkgs.eid-mw ];
      };
in
{

  programs = {
    evince.enable = true;
    nm-applet.enable = true;
  };

  environment.systemPackages = with pkgs; [
    firefox
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

  fonts = {
    fonts = with pkgs; [
      fira-code
      font-awesome
      aileron
      tenderness
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      dejavu_fonts
      liberation_ttf

      corefonts
      vistafonts

      google-fonts
    ];

    fontDir.enable = true;

    fontconfig.defaultFonts = {

      monospace = [ "Fira Code Nerd Font" ];

      sansSerif = [ "Aileron" ];

    };
  };

  stylix = {
    polarity = "light";
    image = ./wallpaper.png;
    fonts = {
      sansSerif = {
        package = pkgs.aileron;
        name = "Aileron";
      };
      serif = {
        package = pkgs.tenderness;
        name = "Tenderness";
      };
      monospace = {
        package = pkgs.fira-code;
        name = "Fira Code";
      };
    };
    targets.gtk.enable = false;
  };
}
