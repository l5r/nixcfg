{ pkgs, config, lib, ... }: {
  imports = (lib.optionals pkgs.stdenv.isLinux [
    ../profiles/sway
    ../profiles/sway/waybar.nix
    ../profiles/spotify.nix
  ]) ++ [
    ../profiles/fish.nix
    ../profiles/kitty.nix
    ../profiles/neovim
    ../profiles/state-version.nix
  ];
}
