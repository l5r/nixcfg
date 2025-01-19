{
  config,
  lib,
  pkgs,
  options,
  ...
}:
{
  config = {
    programs.ssh = lib.mkMerge [
      (lib.optionalAttrs pkgs.stdenv.isLinux {
        startAgent = true;
      })
      {
        extraConfig = ''
          AddKeysToAgent yes
        '';
      }
    ];

    users = lib.optionalAttrs pkgs.stdenv.isLinux {
      defaultShell = pkgs.fish;
    };

    programs.fish.enable = true;

    environment = {

      systemPackages =
        with pkgs;
        [
          binutils
          coreutils
          curl
          direnv
          dnsutils
          dosfstools
          eza
          fd
          git
          git-crypt
          httpie
          jq
          moreutils
          mosh
          ranger
          ripgrep
          sshfs
          whois
        ]
        ++ lib.optionals stdenv.isLinux [
          gotop
          gptfdisk
          iputils
          psmisc
          utillinux
        ];

      shellAliases =
        let
          ifSudo = lib.mkIf (
            (lib.hasAttr "sudo" config.security)
            && ((lib.hasAttr "enable" config.security.sudo) && config.security.sudo.enable)
          );
        in
        {
          # quick cd
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";

          # better ls
          ls = "eza --classify --git";
          ll = "ls -l --header --group";
          la = "ll -a";
          tree = "ls --tree";
          trea = "la --tree";

          # git
          g = "git";

          # grep
          grep = "rg";
          gi = "grep -i";

          # internet ip
          myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

          # nix
          n = "nix";
          np = "n profile";
          ni = "np install";
          nr = "np remove";
          ns = "n search --no-update-lock-file";
          nf = "n flake";
          srch = "ns nixpkgs";
          nrb = ifSudo "sudo nixos-rebuild";

          # sudo
          s = ifSudo "sudo -E ";
          si = ifSudo "sudo -i";
          se = ifSudo "sudoedit";

          # top
          top = "gotop";

          # systemd
          ctl = "systemctl";
          stl = ifSudo "s systemctl";
          utl = "systemctl --user";
          ut = "systemctl --user start";
          un = "systemctl --user stop";
          up = ifSudo "s systemctl start";
          dn = ifSudo "s systemctl stop";
          jtl = "journalctl";

          # ranger
          r = "ranger";
        };

    };
  };
}
