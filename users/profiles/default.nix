{ pkgs, config, lib, ... }: {
  imports = [
    ./dms.nix
    ./niri.nix
    # ../profiles/sway
    # ../profiles/sway/waybar.nix
    ../profiles/spotify.nix
    ../profiles/fish.nix
    ../profiles/helix.nix
    ../profiles/kitty.nix
    # ../profiles/neovim
    ../profiles/state-version.nix
  ];
}
