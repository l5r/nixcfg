{ config, lib, pkgs, ... }:
let
  inherit (lib) fileContents;

in
{
  nix.package = pkgs.nixFlakes;

  imports = [
    ../../local/locale.nix
    ../../modules/neovim.nix
  ];

  environment = {

    systemPackages = with pkgs; [
      binutils
      coreutils
      psmisc
      curl
      httpie
      direnv
      dnsutils
      dosfstools
      fd
      git
      gotop
      gptfdisk
      iputils
      jq
      moreutils
      ripgrep
      utillinux
      whois
      exa
      ranger
    ];

    shellAliases =
      let
        ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # better ls
        ls = "exa --classify --git";
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

  fonts = {
    fonts = with pkgs; [ fira-code font-awesome aileron dejavu_fonts ];

    fontconfig.defaultFonts = {

      monospace = [ "Fira Code Nerd Font" ];

      sansSerif = [ "Aileron" ];

    };
  };

  nix = {

    autoOptimiseStore = true;

    gc.automatic = true;

    optimise.automatic = true;

    useSandbox = true;

    allowedUsers = [ "@wheel" ];

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      min-free = 536870912
    '';

  };

  nixpkgs.config.allowUnfree = true;

  security = {

    protectKernelImage = true;

  };

  services.earlyoom.enable = true;

  users.mutableUsers = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

}
