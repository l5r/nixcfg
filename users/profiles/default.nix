{ pkgs, config, lib, ... }: {
  imports = [
    ../profiles/sway
    ../profiles/sway/waybar.nix
    ../profiles/spotify.nix
    ../profiles/fish.nix
    ../profiles/helix.nix
    ../profiles/kitty.nix
    # ../profiles/neovim
    ../profiles/state-version.nix
  ];
}
