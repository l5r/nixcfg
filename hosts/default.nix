{ home
, lib
, stable
, unstable
, pkgset
, self
, system
, utils
, ...
}:
let
  inherit (utils) recImport;
  inherit (builtins) attrValues removeAttrs;
  inherit (pkgset) osPkgs devPkgs;

  config = hostName:
    lib.nixosSystem {
      inherit system;

      modules =
        let
          inherit (home.nixosModules) home-manager;

          core = self.nixosModules.profiles.core;

          global = {

            imports = [
              "${stable}/nixos/modules/installer/scan/not-detected.nix"
            ];

            networking.hostName = hostName;
            nix.nixPath = let path = toString ../.; in
              [
                "nixpkgs=${stable}"
                "nixpkgs-unstable=${unstable}"
                # "nixos-config=${path}/configuration.nix"
                "nixpkgs-overlays=${path}/overlays"
              ];

            nixpkgs = { pkgs = osPkgs; };

            nix.registry = {
              nixos.flake = stable;
              nixflk.flake = self;
              nixpkgs.flake = stable;
            };
          };

          overrides = {
            # use latest systemd
            # systemd.package = pkgs.systemd;

            nixpkgs.overlays =
              let
                override = import ../pkgs/override.nix stable;

                overlay = pkg: final: prev: {
                  "${pkg.pname}" = pkg;
                };
              in
              map overlay override;
          };

          local = import "${toString ./. }/${hostName}.nix";

          # Everything in `./modules/list.nix`.
          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" ]);

        in
        flakeModules ++ [ core global local home-manager overrides ];

    };

  hosts = recImport {
    dir = ./.;
    _import = config;
  };
in
hosts
