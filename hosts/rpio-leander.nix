{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../users/leander
    ../users/root

    ../profiles/networking/ssh.nix
    ../profiles/networking/printing.nix
    ../profiles/core
    ../profiles/graphical
    ../profiles/laptop.nix
    ../profiles/desktop-extra.nix
    ../profiles/eid.nix
    ../profiles/rpio.nix
    ../modules/applications.nix

    ../modules/rootless.nix

    (modulesPath + "/installer/scan/not-detected.nix")

  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  # boot.loader.grub.enable = false;
  # boot.loader.refind.enable = true;
  # boot.loader.refind.maxGenerations = 20;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
  boot.zfs.package = pkgs.zfs_2_4;

  system.stateVersion = "25.05";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.hostId = "6c469a85";
  networking.hostName = "rpio-leander";
  # networking.interfaces.enp195s0f0u1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp192s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.fwupd.enable = true;
  services.fprintd.enable = true;
  home-manager.sharedModules = [
    ../users/profiles/emacs.nix
    {
      wayland.windowManager.sway = {
        config.output."eDP-1" = {
          scale = "1.75";
        };
      };
    }
  ];

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
      { directory = "/var/lib/nixos"; user = "root"; group = "root"; mode = "0750"; }
    ];
  };

  disko.devices = {
    disk = {
      nvme0n1 = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              priority = 100;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            bpool = {
              size = "4G";
              priority = 200;
              content = {
                type = "zfs";
                pool = "bpool";
              };
            };
            swap = {
              size = "123G";
              priority = 300;
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
              };
            };
            rpool = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      bpool = {
        type = "zpool";
        options = {
          compatibility = "grub2";
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          canmount = "off";
          compression = "lz4";
          devices = "off";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          # "nixos/boot" = {
          #   type = "zfs_fs";
          #   mountpoint = "/boot";
          # };
        };
      };
      rpool = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
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
            size = "64G";
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
