{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    pavucontrol
    sbc # bluetooth codec
  ];

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    powerOnBoot = true;
  };

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
}
