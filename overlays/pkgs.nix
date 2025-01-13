final: prev:
let pkgs = import ../pkgs { inherit (final) callPackage; };
in
pkgs
