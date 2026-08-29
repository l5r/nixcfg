{ callPackage }: rec {
  mu-cli = callPackage ./mu-cli.nix { };
  rpio-tools = callPackage ./rpio-tools.nix { inherit pyshacl; };
  pyshacl = callPackage ./pyshacl.nix { inherit owlrl; };
  owlrl = callPackage ./owlrl.nix { };
}
