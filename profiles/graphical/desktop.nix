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
    adwaita-icon-theme
    elementary-xfce-icon-theme
  ];

  programs.dconf.enable = true;
  services.gnome = {
    # gnome-keyring.enable = true;
    # gnome-online-accounts.enable = true;
  };
  services.gvfs.enable = true;
  services.pantheon.contractor.enable = true;

  fonts = {
    packages = with pkgs; [
      fira-code
      font-awesome
      aileron
      tenderness
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf

      corefonts
      vista-fonts

      google-fonts
    ];

    fontDir.enable = true;

    fontconfig.defaultFonts = {

      monospace = [ "Fira Code Nerd Font" ];

      sansSerif = [ "Aileron" ];

    };
  };

  stylix = {
    enable = true;
    polarity = "light";
    image = ./wallpaper.jpg;
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
