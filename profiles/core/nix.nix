{ config, lib, pkgs, inputs, channels, options, ... }: {

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
          id = "nixpkgs";
        };
        flake = inputs.stable;
      };
    };
  };

  # nixpkgs.config.allowUnfree = true;
  services = lib.optionalAttrs (builtins.hasAttr "nix-daemon" options.services) {
    nix-daemon.enable = lib.optionalAttrs pkgs.stdenv.isDarwin true;
  };
}
