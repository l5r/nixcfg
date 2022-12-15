let
  secrets = import ../secrets;
  userConfig = {
    hashedPassword = secrets.root.hashedPassword;
    openssh = {
      authorizedKeys = secrets.ssh.authorizedKeys;
    };
  };
in
{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ../profiles/networking/services.nix
  ];

  users.users.root = userConfig;
  users.users.nixos = userConfig;

  nixpkgs.config.allowUnfree = true;

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
}
