{
  description = "A highly structured configuration database.";

  inputs =
    {
      unstable.url = "nixpkgs/nixos-unstable";
      stable.url = "nixpkgs/nixos-22.05";
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
    , stable
    , unstable
    , nix-darwin
    , stylix
    }:
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };
      channels.nixpkgs = {
        input = stable;
        overlaysBuilder = channels: [
          (final: prev: { inherit (channels.unstable) /* Unstable packages here */; })
        ];
      };

      #########
      # Hosts
      #########

      hosts.spookje.modules = [
        home.nixosModules.home-manager
        stylix.nixosModules.stylix
        ./hosts/spookje.nix
      ];

      hosts.ligma = {
        system = flake-utils-plus.systems.aarch64-darwin;
        output = "darwinConfigurations";
        builder = nix-darwin.lib.darwinSystem;
        modules = [
          home.darwinModules.home-manager
          ./hosts/ligma.nix
        ];
      };

    };
}
