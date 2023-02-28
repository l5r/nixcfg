{ lib
, buildNpmPackage
, fetchFromGitHub

, nodePackages
, python3
}:
let
  version = "0.101.2";

  githubSrc = fetchFromGitHub {
    owner = "nocodb";
    repo = "nocodb";
    rev = version;
    sha256 = "ON5LrTi0BUbuAol2NCfJOxbrVlJy38K8N+YMt2RKv0Q=";
  };
in
buildNpmPackage rec {
  inherit version;

  pname = "nocodb";
  src = "${githubSrc}/packages/nocodb";

  patches = [ ./nocodb-bin.patch ];

  npmDepsHash = "sha256-0a9bHzuWtw9LcsYZ2YcgIWQEOo0NkBQVsfOJmU/565c=";
  npmBuildScript = "build";

  nativeBuildInputs = [ nodePackages.node-pre-gyp python3 ];

  NODE_OPTIONS = "--openssl-legacy-provider";
}
