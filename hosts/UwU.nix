{ lib, ... }: {
  ### root password is empty by default ###
  imports = [
    ../users/leander
    ../users/root

    ../profiles/laptop.nix
    ../modules/zfs.nix
    ../modules/applications.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostId = "cafebabe";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/90A7-80CD";
      fsType = "vfat";
    };

  # rootless.enable = true;

  nix.maxJobs = lib.mkDefault 4;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  system.stateVersion = "20.09";
}
