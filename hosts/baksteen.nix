{ lib, pkgs, ... }: {
  ### root password is empty by default ###
  imports = [
    ../users/leander
    ../users/root

    ../profiles/laptop.nix
    ../profiles/devel/racket.nix
    ../modules/zfs.nix
    ../modules/applications.nix
    ../profiles/teams.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostId = "d080ce41";

  services.zfs.autoReplication.identityFilePath = ../secrets/zbackup_baksteen_id_rsa;

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/8D8E-8D7E";
      fsType = "vfat";
    };

  rootless.enable = true;
  virtualisation.docker.enable = true;

  nix.maxJobs = lib.mkDefault 4;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_5_14;

  system.stateVersion = "21.05";

}
