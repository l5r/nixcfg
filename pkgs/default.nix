final: prev: {
  steam = prev.steam.override {
    extraPkgs = pkgs: [ pkgs.libpng pkgs.gcc ];
    extraLibraries = pkgs: [ pkgs.pipewire ];
  };
}
