let secrets = import ../../secrets; in
{inputs, ...}: {
  home-manager.users.root.imports = [
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
    ../profiles/sway
    # ../profiles/neovim
    ../profiles/fish.nix
    ../profiles/helix.nix
    ../profiles/state-version.nix
  ];
  users.users.root.hashedPassword = secrets.root.hashedPassword;
  users.users.root.openssh = {
    authorizedKeys = secrets.ssh.authorizedKeys;
  };
}
