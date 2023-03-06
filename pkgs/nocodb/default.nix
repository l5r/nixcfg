{ lib
, buildNpmPackage
, fetchFromGitHub

, nodePackages
, python3
}:
let
  version = "0.105.3";
in
buildNpmPackage rec {
  inherit version;

  pname = "nocodb";
  src = ./.;

  npmDepsHash = "sha256-aSLAelsKVy4U84WHGY3QrPLBjgCAOvxmDv0nmr3n+qs=";

  nativeBuildInputs = [ nodePackages.node-pre-gyp python3 ];
}
