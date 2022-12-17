{ system, config, lib, pkgs, inputs, ... }: {

  nix = {
    gc.automatic = true;

    settings = {
      sandbox = true;
      allowed-users = [ "@wheel" "@staff" "@admin" ];
      trusted-users = [ "root" "@wheel" "@staff" "@admin" ];
      auto-optimise-store = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      min-free = 536870912
    '';

    registry = {
      nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgspin";
        };
        flake = inputs.stable;
      };
    };
  };

  nixpkgs.config.allowUnfree = true;
  # services.nix-daemon.enable = true;
}
