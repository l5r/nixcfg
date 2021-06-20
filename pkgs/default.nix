final: prev: {
  steam = prev.steam.override {
    extraPkgs = pkgs: [ pkgs.libpng pkgs.gcc ];
    extraLibraries = pkgs: [ pkgs.pipewire ];
  };
  startsway = prev.writeScriptBin "startsway"
    ''# first import environment variables from the login manager
      systemctl --user import-environment
      # then start the service
      exec systemctl --user start sway.service
    '';
}
