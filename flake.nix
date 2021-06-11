{
  description = "A highly structured configuration database.";

  inputs =
    {
      unstable.url = "nixpkgs/nixos-unstable";
      stable.url = "nixpkgs/nixos-21.05";
      # home.url = "github:nix-community/home-manager/release-20.09";
      # home.url = "/home/leander/p/home-manager";
      home.url = "github:l5r/home-manager?rev=95da56b783e4ccc8ded71137e4add780b239dd46";
    };

  outputs = inputs@{ self, home, stable, unstable }:
    let
      inherit (builtins) attrNames attrValues readDir;
      inherit (stable) lib;
      inherit (lib) removeSuffix recursiveUpdate genAttrs filterAttrs;
      inherit (utils) pathsToImportedAttrs;

      utils = import ./lib/utils.nix { inherit lib; };

      system = "x86_64-linux";

      pkgImport = pkgs:
        import pkgs {
          inherit system;
          overlays = attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgset = {
        osPkgs = pkgImport stable;
        devPkgs = pkgImport unstable;
      };

    in
      with pkgset;
      {
        nixosConfigurations =
          import ./hosts (
            recursiveUpdate inputs {
              inherit lib pkgset system utils;
            }
          );

        devShell."${system}" = import ./shell.nix {
          pkgs = devPkgs;
        };

        overlay = import ./pkgs;

        overlays =
          let
            overlayDir = ./overlays;
            fullPath = name: overlayDir + "/${name}";
            overlayPaths = map fullPath (attrNames (readDir overlayDir));
          in
            pathsToImportedAttrs overlayPaths;

        packages."${system}" =
          let
            packages = self.overlay osPkgs osPkgs;
            overlays = lib.filterAttrs (n: v: n != "pkgs") self.overlays;
            overlayPkgs =
              genAttrs
                (attrNames overlays)
                (name: (overlays."${name}" osPkgs osPkgs)."${name}");
          in
            recursiveUpdate packages overlayPkgs;

        nixosModules =
          let
            # binary cache
            cachix = import ./cachix.nix;
            cachixAttrs = { inherit cachix; };

            # modules
            moduleList = import ./modules/list.nix;
            modulesAttrs = pathsToImportedAttrs moduleList;

            # profiles
            profilesList = import ./profiles/list.nix;
            profilesAttrs = { profiles = pathsToImportedAttrs profilesList; };

          in
            recursiveUpdate
              (recursiveUpdate cachixAttrs modulesAttrs)
              profilesAttrs;

        templates.flk.path = ./.;
        templates.flk.description = "flk template";

        defaultTemplate = self.templates.flk;
      };
}
