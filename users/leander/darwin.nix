let
  secrets = import ../../secrets;
in
{ pkgs, config, lib, ... }: {
  users.users.leander = {
    name = "leander";
    home = "/Users/leander/";
  };
  home-manager.useGlobalPkgs = true;
  home-manager.users.leander = {
    imports = [
      ../profiles/fish.nix
      ../profiles/neovim
      ../profiles/state-version.nix
    ];
  };
}
