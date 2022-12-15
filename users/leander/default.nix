let
  secrets = import ../../secrets;
in
{ pkgs, config, lib, ... }@args: {
  home-manager.users.leander = {
    imports = [
      ../profiles/default.nix
    ];
  };
  users.users.leander = {
    uid = 1000;
    hashedPassword = secrets.leander.hashedPassword;
    openssh = {
      authorizedKeys = secrets.ssh.authorizedKeys;
    };
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "adbusers" "scanner" "lp" "video" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
