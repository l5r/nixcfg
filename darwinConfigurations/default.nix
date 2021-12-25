{ home
, lib
, stable
, unstable
, pkgset
, self
, system
, utils
, darwin
, ...
}:
let
  inherit (utils) recImport;
  inherit (builtins) attrValues removeAttrs;
  inherit (pkgset) osPkgs devPkgs;

  config = hostName:
    darwin.lib.darwinSystem {
      inherit system;
      modules = [
        home.darwinModule
        ./${hostName}.nix
      ];
      inputs = {
	inherit home lib system utils darwin;
        unstable = pkgset.devPkgs;
	nixpkgs = stable;
	pkgs = stable;
      };
    };

  darwins = recImport {
    dir = ./.;
    _import = config;
  };
in
darwins
