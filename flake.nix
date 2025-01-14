{
  description = "A highly structured configuration database.";

  nixConfig = {
    extra-substituters = [
      "https://colmena.cachix.org"
    ];
    extra-trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
    ];
  };

  inputs =
    {
      unstable.url = "nixpkgs/nixos-unstable";
      stable.url = "nixpkgs/nixos-24.11";
      nixos-24-05.url = "nixpkgs/nixos-24.05";
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

      colmena-flake.url = "github:zhaofengli/colmena";

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
    , colmena-flake
    , flake-utils-plus
    , home
    , impermanence
    , nixos-24-05
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
          (final: prev: { inherit (channels.unstable) /* Unstable packages here */; })
          # Downgrade transmission 4 to 4.0.5
          (final: prev: { inherit (channels.nixos-24-05) transmission_4; })
          (final: prev: {
            vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
          })
          colmena-flake.overlays.default
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
        };

        devShell = channels.nixpkgs.mkShell {
          packages = [
            channels.nixpkgs.ragenix
            channels.nixpkgs.rage
            channels.nixpkgs.git-crypt
            channels.nixpkgs.colmena
            channels.nixpkgs.nil
          ];
        };
      };

      colmenaHive = colmena-flake.lib.makeHive self.outputs.colmena;

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
