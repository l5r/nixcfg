{ config, pkgs, ... }: {

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_vi_key_bindings
      set -x EDITOR nvim
    '';

    shellAliases = {
      ls = "exa --classify --git";
      ll = "ls -l --header --group";
      la = "ll -a";
      tree = "ls --tree";
      trea = "la --tree";
    };

    shellAbbrs = {
      r = "ranger";
      nrs = "sudo nixos-rebuild switch";
    };

    functions = {
      mkcd = "mkdir -p $argv; cd $argv";
      # klok = ''
      #   echo '{"token": "${credentials.mattermost.token}", "text": "'"$argv"'"}' |\
      #     /usr/bin/http POST 'matterklok.rave.org/settings' --json --body
      # '';
      mnt = {
        description = "Mount a filesystem using gvfs and fzf";
        body = ''
          gio mount -d "/dev/"(lsblk --list | fzf | cut -d " " -f 1)
        '';
      };
      cdm = {
        description = "Cd into a mounted filesystem using fzf";
        body = ''
          cd (gio mount -l | grep "file://.*" -o | sed s@file://@@ | fzf)
        '';
      };
    };
  };

  programs.fzf = {
    enable = true;
  };
}
