{ lib
, buildDotnetModule
, fetchFromGitHub
, buildNpmPackage
, dotnet-sdk_7
, dotnetCorePackages
, msbuild
, pkg-config
, mono
, ...
}:
buildDotnetModule rec {
  pname = "slskd";
  version = "0.16.39";

  src = fetchFromGitHub {
    owner = "slskd";
    repo = "slskd";
    rev = version;
    sha256 = "5PWjgGahTFZ2NVOX5hfhdkqmLqtnr3hFUs4tdT7doSk=";
  };
  wwwroot = buildNpmPackage {
    inherit src version;
    pname = "${pname}-wwwroot";
    sourceRoot = "source/src/web";
    npmDepsHash = "sha256-39pv907GFZg/ZJE8i9lvzz/TZKthsbnfc3mP/iIuEVg=";
    installPhase = "cp -r build $out";
  };
  projectFile = "slskd.sln";
  nugetDeps = ./deps.nix;
  postUnpack = ''
    cp -r $wwwroot/* source/src/slskd/wwwroot
  '';
  patches = [ ../../patches/slskd-cotnent-path.patch ];

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.sdk_7_0;
  runtimeDeps = [ mono ];

  executables = [ "slskd" ];
}
