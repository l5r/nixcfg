{ lib, pkgs, config, modulesPath, ... }: {
  imports = [
    ../users/leander
    ../users/root

    ../profiles/desktop.nix
    ../profiles/devel/default.nix
    ../modules/zfs.old.nix
    ../modules/applications.nix
    # ../profiles/teams.nix

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fwupd.enable = true;

  networking.networkmanager.enable = true;
  networking.hostId = "deadbeef";

  services.zfs.autoReplication.identityFilePath = ../secrets/zbackup_spookje_id_rsa;

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/A0A3-486C";
      fsType = "vfat";
    };

  rootless.enable = true;
  # virtualisation.docker.enable = true;

  hardware.opengl = {
    extraPackages = [
      pkgs.amdvlk
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
      # pkgs.rocm-opencl-icd
      # pkgs.rocm-opencl-runtime
    ];
  };

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  system.stateVersion = "20.09";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
