{ config, lib, pkgs, ... }: {
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    epson-escpr
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
  ];

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
}
