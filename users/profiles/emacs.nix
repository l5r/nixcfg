{ pkgs, ...}: let
  emacs = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (
    epkgs: [ epkgs.evil epkgs.base16-theme epkgs.slime ]
  );
in {

  stylix.targets.emacs.enable = false;

  programs.emacs = {
    enable = true;
    package = emacs;
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
    '';
  };
}
