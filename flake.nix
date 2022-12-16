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
        ];
      };

      #########
      # Hosts
      #########

      hosts.spookje.modules = linuxModules ++ [
        ./hosts/spookje.nix
      ];

      hosts.storig.modules = [
        ./hosts/storig.nix
        impermanence.nixosModule
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
          ./hosts/ligma.nix
        ];
      };

      outputsBuilder = channels: {
        devShell = channels.nixpkgs.mkShell {
          packages = [
            channels.nixpkgs.ragenix
            channels.nixpkgs.age
            channels.nixpkgs.git-crypt
            channels.nixpkgs.colmena
          ];
        };
      };

      colmena = {
        meta = {
          nixpkgs = self.pkgs.x86_64-linux.stable;
        };

        storig = {
          imports = hosts.storig.modules;
          deployment.targetHost = secrets.ips.storig;
        };
      };
    };
}
