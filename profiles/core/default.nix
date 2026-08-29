{ config, lib, pkgs, options, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix

    ../../local/locale.nix
    # ../../modules/neovim.nix
  ];
} //
lib.mkMerge [
  {

    nix.package = pkgs.nixVersions.stable;

    security = {

      protectKernelImage = true;

    };

    services.earlyoom.enable = true;

    users.mutableUsers = false;

    environment.systemPackages = [ pkgs.helix pkgs.nil ];
    environment.variables.EDITOR = "hx";

  }  
  (
    lib.optionalAttrs (builtins.hasAttr "home-manager" options) {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }
  )
]

