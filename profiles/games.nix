{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.steam
    pkgs.steam.run
    # pkgs.polymc
  ];

  # Steam is 32-bit
  services.pulseaudio.support32Bit = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    mesa
    libva
    libva-vdpau-driver
  ];

  hardware.graphics.extraPackages = with pkgs; [
    mesa
    libva
    libva-vdpau-driver
  ];

  fileSystems."/mnt/steam" = {
    device = "rpool/secure/steam";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  programs.steam.enable = true;

}
