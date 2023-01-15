{
  description = "A highly structured configuration database.";

  inputs =
    {
      unstable.url = "nixpkgs/nixos-unstable";
      stable.url = "nixpkgs/nixos-22.11";
      home = {
        url = "github:nix-community/home-manager/release-22.05";
        inputs.nixpkgs.follows = "stable";
      };
      nix-darwin = {
        url = "github:lnl7/nix-darwin/master";
        inputs.nixpkgs.follows = "stable";
      };
      flake-utils-plus = {
        url = "github:gytis-ivaskevicius/flake-utils-plus";
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
        url = "github:danth/stylix";
        inputs.nixpkgs.follows = "stable";
        inputs.home-manager.follows = "home";
      };
    };

  outputs =
    inputs@{ self
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
      channels.nixpkgs = {
        input = stable;
        overlaysBuilder = channels: [
          agenix.overlays.default
          (final: prev: { inherit (channels.unstable) /* Unstable packages here */; })
          (final: prev: prev.lib.recursiveUpdate prev
            (import ./pkgs { inherit (final) callPackage; }))
          (final: prev: {
            vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
          })
          (final: prev: {
            python3 = prev.python3.override {
              packageOverrides = pFinal: pPrev: {
                sqlalchemy-json = final.callPackage ./pkgs/sqlalchemy-json.nix
                  { python3Packages = pFinal; };
                aubio = pPrev.aubio.overridePythonAttrs (prev: {
                  nativeBuildInputs = prev.buildInputs ++ [
                    final.pkg-config
                  ];
                  propagatedBuildInputs =
                    (prev.propagatedBuildInputs or [ ]) ++
                    [ final.ffmpeg.out.dev ];
                  # version = "0.5.0-beta";
                  # src = final.fetchFromGitHub {
                  #   owner = "aubio";
                  #   repo = "aubio";
                  #   rev = "8a05420e5dd8c7b8b2447f82dc919765876511b3";
                  #   sha256 = "um+9EvM/nMngn4jaRK44ACIe2TDhYzmQc4t4myBcj8Y=";
                  # };
                });
              };
            };
            python3Packages = final.python3.pkgs;
          })
          (final: prev:
            let
              callBeetsPlugin = path: final.callPackage path {
                beets = final.beetsPackages.beets-minimal;
              };
            in
            prev.lib.recursiveUpdate prev {
              beetsPackages.yt-dlp = callBeetsPlugin ./pkgs/beets-yt-dlp.nix;
              beetsPackages.bpmanalyser = callBeetsPlugin ./pkgs/beets-bpmanalyser.nix;
            })
          (final: prev: {
            beetsPackages = prev.beetsPackages // {
              beets-stable = prev.beetsPackages.beets-stable.override {
                pluginOverrides = {
                  yt-dlp = {
                    enable = true;
                    propagatedBuildInputs = [
                      final.beetsPackages.yt-dlp
                    ];
                  };
                  bpmanalyser = {
                    enable = true;
                    propagatedBuildInputs = [
                      final.beetsPackages.bpmanalyser
                      final.aubio
                    ];
                  };
                };
              };
            };
            beets = final.beetsPackages.beets-stable;
          })
          (final: prev: prev.lib.recursiveUpdate prev {
            beetsPackages.beets-stable = prev.beetsPackages.beets-stable.overridePythonAttrs
              (prev: {
                patches = prev.patches ++ [
                  ./patches/beets-lossless-codecs.patch
                ];
              });
          })
        ];
      };

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

      ###########
      # Outputs #
      ###########
      outputsBuilder = channels: {
        inherit channels;

        packages = {
          inherit (channels.nixpkgs) ffmpegfs;
          inherit (channels.nixpkgs.beetsPackages) beets-yt-dlp beets-bpmanalyser;
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
