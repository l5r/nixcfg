{
  description = "A highly structured configuration database.";

  inputs =
    {
      unstable.url = "nixpkgs/nixos-unstable";
      stable.url = "nixpkgs/nixos-24.11";
      home = {
        url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "stable";
      };
      nix-darwin = {
        url = "github:lnl7/nix-darwin/master";
        inputs.nixpkgs.follows = "stable";
      };
      flake-utils-plus = {
        url = "github:gytis-ivaskevicius/flake-utils-plus";
      };

      bestellinator = {
        url = "github:l5r/bestellinator";
        inputs = {
          nixpkgs.follows = "stable";
        };
      };

      impermanence.url = "github:nix-community/impermanence";
      agenix = {
        url = "github:yaxitech/ragenix";
        inputs = {
          nixpkgs.follows = "stable";
          flake-utils.follows = "flake-utils-plus";
        };
      };

      stylix = {
        url = "github:danth/stylix/release-24.11";
        inputs.nixpkgs.follows = "stable";
        inputs.home-manager.follows = "home";
      };
    };

  outputs =
    inputs@{ self
    , bestellinator
    , flake-utils-plus
    , home
    , impermanence
    , nix-darwin
    , stable
    , stylix
    , unstable
    , agenix
    }:
    let
      linuxModules = [
        home.nixosModules.home-manager
        stylix.nixosModules.stylix
        impermanence.nixosModule
        agenix.nixosModules.age
      ];
      secrets = import ./secrets;
    in
    flake-utils-plus.lib.mkFlake rec {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };
      channels.unstable.overlaysBuilder = channels: [ (import ./overlays/pkgs.nix) ];
      channels.nixpkgs = {
        input = stable;
        overlaysBuilder = channels: [
          agenix.overlays.default
          (import ./overlays/pkgs.nix)
          (final: prev: {
            bestellinator = bestellinator.packages.${channels.nixpkgs.system}.bestellinator;
          })
          (final: prev: { inherit (channels.unstable) /* Unstable packages here */; })
          (final: prev: {
            vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
          })
          (import ./overlays/beets-plugins.nix)
          (final: prev: {
            beetsPackages = prev.beetsPackages // {
              beets-stable = prev.beetsPackages.beets-stable.overridePythonAttrs
                (prev: {
                  patches = prev.patches ++ [
                    ./patches/beets-lossless-codecs.patch
                  ];
                });
            };
          })
          (final: prev: {
            gonic = prev.gonic.override {
              buildGoModule = args: channels.unstable.buildGoModule (args // rec {
                version = "0.16.0";
                src = final.fetchFromGitHub {
                  owner = "sentriz";
                  repo = "gonic";
                  rev = "v${version}";
                  sha256 = "sha256-BkO6PIUoUHpEDnxCNSvLcLN5LGjaJfyhYLFARnG1JHY=";
                };
                vendorHash = "sha256-wRX6l56kbYiH4QaxzMaPKeaJJ3h48+Xr2KGKqPBIDoo=";
                doCheck = false;
              });
            };
          })
        ];
      };

      nixosModules = flake-utils-plus.lib.exportModules [
        modules/paths.nix
        modules/reverse-proxy.nix
        modules/slskd.nix
        modules/wg-container.nix
      ];

      #########
      # Hosts
      #########

      hostDefauts.extraArgs = {
        channels = self.channels;
        inherit inputs;
      };

      hosts.spookje.modules = linuxModules ++ [
        ./hosts/spookje.nix
      ];

      hosts.storig.modules = [
        ./hosts/storig.nix
        impermanence.nixosModule
        agenix.nixosModules.age
      ];

      hosts.niximg.modules = [
        ./hosts/niximg.nix
      ];

      hosts.ligma = {
        system = flake-utils-plus.lib.system.aarch64-darwin;
        output = "darwinConfigurations";
        builder = nix-darwin.lib.darwinSystem;
        modules = [
          home.darwinModules.home-manager
          ./darwinConfigurations/ligma.nix
        ];
      };

      hosts.smugjug = {
        system = flake-utils-plus.lib.system.aarch64-darwin;
        output = "darwinConfigurations";
        builder = nix-darwin.lib.darwinSystem;
        modules = [
          home.darwinModules.home-manager
          ./darwinConfigurations/smugjug.nix
        ];
      };

      ###########
      # Outputs #
      ###########
      overlays = flake-utils-plus.lib.exportOverlays {
        inherit (self) pkgs inputs;
      };

      outputsBuilder = channels: {
        inherit channels;

        packages = flake-utils-plus.lib.exportPackages self.overlays channels // {
          inherit (channels.nixpkgs) ffmpegfs;
          inherit (channels.nixpkgs.beetsPackages) beets-bpmanalyser;
        };

        devShell = channels.nixpkgs.mkShell {
          packages = [
            channels.nixpkgs.ragenix
            channels.nixpkgs.rage
            channels.nixpkgs.git-crypt
            channels.nixpkgs.colmena
          ];
        };
      };

      colmena = {
        meta = {
          nixpkgs = self.channels.x86_64-linux.nixpkgs;
          specialArgs = {
            channels = self.channels;
            inherit inputs;
          };
        };

        storig = {
          imports = hosts.storig.modules;
          deployment.targetHost = secrets.ips.storig;
        };
      };
    };
}
