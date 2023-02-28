final: prev:
let pkgs = import ../pkgs { inherit (final) callPackage; };
in
pkgs // {
  beetsPackages = prev.beetsPackages // pkgs.beetsPackages;
}
