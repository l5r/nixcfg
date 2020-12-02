{ lib, pkgs, ... }: {
  imports = [
    ../users/leander
    ../users/root

    ../profiles/desktop.nix
    ../modules/zfs.nix
    ../modules/applications.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostId = "deadbeef";

  services.zfs.autoReplication.identityFilePath = ../secrets/zbackup_spookje_id_rsa;

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A0A3-486C";
      fsType = "vfat";
    };

  rootless.enable = true;
  virtualisation.docker.enable = true;

  nix.maxJobs = lib.mkDefault 12;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_5_8;

  system.stateVersion = "20.09";
}
