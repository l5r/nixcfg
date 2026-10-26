{ lib, pkgs, config, modulesPath, ... }: {
  imports = [
    ../users/leander
    ../users/root

    ../profiles/core
    ../profiles/graphical
    ../profiles/networking
    ../profiles/networking/nas.nix
    ../profiles/laptop.nix
    ../modules/applications.nix

    ../modules/rootless.nix

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = [
    pkgs.mixxx
    pkgs.qlcplus
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;

  system.stateVersion = "26.05";

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.hostId = "6c469a85";
  networking.hostName = "cristal";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.fwupd.enable = true;

  rootless = {
    enable = true;
    zfsPart = "rpool/secure/nixos/root";
    dataPaths = [
      "/etc/nixos"
    ];
  };
  environment.persistence."/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    directories = [
    ];
  };

  disko.devices = {
    disk={
      rpoolpart = {
        device ="/dev/disk/by-partuuid/0b4167a3-c649-4bc4-9698-1d919a773b33";
        type = "disk";
        content = {
          type = "zfs";
          pool = "rpool";
        };
      };
    };
    zpool = {
      rpool ={
        type = "zpool";
        options = {
          ashift="12";
          autotrim="on";
        };

        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          devices = "off";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };


        datasets = {
          "secure" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "on";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          "secure/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
          "secure/nixos" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "secure/nixos/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = "zfs snapshot rpool/secure/nixos/root@blank";
          };
          "secure/nixos/var/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options.mountpoint = "legacy";
          };
          "secure/nixos/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          "secure/nixos/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };

          "reserve" = {
            type = "zfs_volume";
            size = "16G";
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/boot" = {
    device = "/dev/disk/by-partuuid/f8ceeec8-ccc0-442c-89b3-2eca3dbfcb6c";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-partuuid/dd05b6af-3ea0-405e-9f00-f4e2343495eb"; }
  ];
}
