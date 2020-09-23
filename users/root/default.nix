let secrets = import ../../secrets; in
{
  home-manager.users.root.imports = [
    ../profiles/sway
    # ../profiles/neovim
    ../profiles/fish.nix
    ../profiles/state-version.nix
  ];
  users.users.root.hashedPassword = secrets.root.hashedPassword;
}
