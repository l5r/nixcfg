{ pkgs, ... }: {

  imports = [
    # Temporary
    # ../profiles/graphical/xfce.nix
  ];

  environment.systemPackages = [ pkgs.ungoogled-chromium pkgs.teams ];
}
