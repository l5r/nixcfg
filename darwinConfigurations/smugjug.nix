{ darwin, pkgs, inputs, ... }: {
  imports = [
    ../profiles/core/darwin.nix
    ../profiles/homebrew.nix
    ../profiles/macos-settings.nix
    ../users/leander/darwin.nix
  ];

  # nixpkgs.config = {
  #   allowUnsupportedSystem = true;
  #   allowBroken = true;
  # };

  environment.shells = [ pkgs.fish ];
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
  programs.fish.enable = true;

  networking = let hostName = "smugjug"; in
    {
      hostName = hostName;
      computerName = hostName;
      localHostName = hostName;
    };

  system.stateVersion = 4;
}
