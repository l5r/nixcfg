{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.steam
    pkgs.steam.run
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

  programs.steam.enable = true;

}
