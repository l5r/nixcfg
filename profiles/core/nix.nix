{ system, config, lib, pkgs, inputs ? false, ... }: {

  nix = {
    gc.automatic = true;

    useSandbox = true;
    useDaemon = true;

    allowedUsers = [ "@wheel" "@staff" "@admin" ];
    trustedUsers = [ "root" "@wheel" "@staff" "@admin" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      min-free = 536870912
    '';
  };

  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
}
