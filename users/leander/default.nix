let
  secrets = import ../../secrets;
in
{ pkgs, config, lib, ... }@args: {
  home-manager.users.leander = {
    imports = [
      ../profiles/default.nix
      {
        programs.git.userName = "Leander Lismond";
        programs.git.userEmail = "36822732+l5r@users.noreply.github.com";
      }
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
    extraGroups = [
      "wheel" "networkmanager" "docker" "adbusers" "scanner" "lp" "video"
      "render" "cdrom"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
