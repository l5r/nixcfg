{ lib, pkgs, config, ...}: {
  services.kanshi = {
    enable = true;
    profiles = {
      docked = {
        outputs = [
          { criteria = "Samsung Electric Company S24D390 H4MG805432"; position = "0,0"; }
          { criteria = "eDP-1"; position = "0,1080"; }
        ];
      };
      normal = {
        outputs = [
          { criteria = "eDP-1"; position = "0,0"; }
        ];
      };
    };
  };
}

