{
  inputs = {
    nixpkgs.url = "github:nixos/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
    terranix = {
      url = "github:l5r/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, terranix }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          buildTerranix = terranix.lib.buildTerranix;
          name = "l5r-terranix";
        in
          rec {
            packages = {
              ${name} = buildTerranix {
                inherit pkgs;
                terranix_config = {
                  imports = [ ./proxmox.nix ];
                  providers.proxmox = {
                    enable = true;
                    initialSSHKeys = [];
                    initialNixPkgs = nixpkgs.outPath;
                    nodes = {
                      storig = {
                        system = "x86_64-linux";
                        ipv6Address = "fda8:4ac5:c10a:8de5:0799:93fe:92e3:bad0";
                        ipv4Address = "172.24.115.128";
                        nixOSContainerTemplateDatastore = "local";
                        containers = {
                          builder = {
                            id = 101;
                            ipv4 = "10.10.10.101/32";
                            ipv6 = "fe80::6969:0:0101/64";
                            mountpoints = {
                              "/" = {
                                id = 1;
                                storage = "naspool1";
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };

            defaultPackage = packages.${name};
            devShell = pkgs.mkShell {
              buildInputs = [ pkgs.terraform_0_15 ];
            };
          }
    );
}
