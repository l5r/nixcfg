{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    pwvucontrol
    sbc # bluetooth codec
  ];

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    powerOnBoot = true;
  };

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
}
