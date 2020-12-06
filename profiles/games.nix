{ pkgs, config, ... }:
let
  steam = pkgs.steam.override {
    extraPkgs = pkgs: [ pkgs.libpng ];
  };
in
{
  environment.systemPackages = [
    steam
    steam.run
    pkgs.multimc
  ];

  # Steam is 32-bit
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    mesa
    libva
    vaapiVdpau
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    mesa
    libva
    vaapiVdpau
  ];

  fileSystems."/mnt/steam" = {
    device = "rpool/secure/steam";
    fsType = "zfs";
    options = [ "nofail" ];
  };

}
