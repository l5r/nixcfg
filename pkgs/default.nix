{ callPackage }: {
  mu-cli = callPackage ./mu-cli.nix {};
  rpio-tools = callPackage ./rpio-tools.nix {};
}
