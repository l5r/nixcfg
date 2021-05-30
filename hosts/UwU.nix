{ lib, pkgs, ... }: {
  ### root password is empty by default ###
  imports = [
    ../users/leander
    ../users/root

    ../profiles/laptop.nix
    ../profiles/devel/racket.nix
    ../modules/zfs.nix
    ../modules/applications.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostId = "cafebabe";

  services.zfs.autoReplication.identityFilePath = ../secrets/zbackup_uwu_id_rsa;

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/90A7-80CD";
      fsType = "vfat";
    };

  rootless.enable = true;
  virtualisation.docker.enable = true;

  nix.maxJobs = lib.mkDefault 4;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [];
  boot.kernelPackages = pkgs.linuxPackages_5_8;

  system.stateVersion = "20.09";

}
