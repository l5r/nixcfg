let secrets = import ../../secrets; in
{ pkgs, config, lib, ... }@args: {
  home-manager.users.leander = {
    imports = [
      ../profiles/sway
      ../profiles/sway/waybar.nix
      ../profiles/fish.nix
      ../profiles/neovim
      ../profiles/state-version.nix
    ];
  };
  users.users.leander = {
    uid = 1000;
    hashedPassword = secrets.leander.hashedPassword;
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
