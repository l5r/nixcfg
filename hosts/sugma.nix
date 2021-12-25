{ modulesPath, ... }: {
  imports = [
    # passwd is nixos by default
    ../users/nixos
    # passwd is empty by default
    ../users/root
    ../modules/applications.nix
    ../profiles/graphical
  ];

  virtualisation.docker.enable = true;

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  networking.networkmanager.enable = true;
}
