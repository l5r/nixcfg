let
  secrets = import ../../secrets;
in
{ pkgs, config, lib, ... }: {
  users.users.leander = {
    name = "leander";
    home = "/Users/leander/";
    shell = pkgs.fish;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.users.leander = {
    imports = [
      ../profiles/fish.nix
      # ../profiles/neovim
      ../profiles/state-version.nix
    ];
  };

  security.pam.enableSudoTouchIdAuth = true;
}
