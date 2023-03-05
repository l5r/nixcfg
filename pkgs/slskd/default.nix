{ lib
, buildDotnetModule
, fetchFromGitHub
, buildNpmPackage
, dotnet-sdk_7
, dotnetCorePackages
, msbuild
, pkg-config
, mono
, pkgs
, stdenv
, ...
}:
buildDotnetModule rec {
  pname = "slskd";
  version = "0.17.4";

  src = fetchFromGitHub {
    owner = "slskd";
    repo = "slskd";
    rev = version;
    sha256 = "D5mrS2HF03PP87zlLP5cxWqjvc/U5k338UOV5CpORXA=";
  };
  nodeDependencies = (pkgs.callPackage ./web.nix {
    src = "${src}/src/web";
  }).nodeDependencies.override { npmFlags = "--legacy-peer-deps"; };
  wwwroot = stdenv.mkDerivation {
    inherit version;
    src = "${src}/src/web";
    pname = "${pname}-wwwroot";
    nativeBuildInputs = [ nodeDependencies pkgs.nodejs-18_x ];
    buildPhase = ''
      cp -r ${nodeDependencies}/lib/node_modules ./
      chmod -R 700 node_modules

      npm run build --offline
    '';
    installPhase = "cp -r build $out";
  };
  projectFile = "slskd.sln";
  nugetDeps = ./deps.nix;
  postUnpack = ''
    cp -r $wwwroot/* source/src/slskd/wwwroot
  '';

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.sdk_7_0;
  runtimeDeps = [ mono ];

  executables = [ "slskd" ];
}
