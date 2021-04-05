{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    pavucontrol
    sbc # bluetooth codec
  ];

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    powerOnBoot = true;
  };

  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };

  services.pipewire.enable = true;
}
