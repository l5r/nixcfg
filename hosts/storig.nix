let
  secrets = import ../secrets/default.nix;
  userConfig = {
    hashedPassword = secrets.root.hashedPassword;
    openssh = {
      authorizedKeys = secrets.ssh.authorizedKeys;
    };
  };
in
{ lib, pkgs, config, modulesPath, ... }: {
  imports = [
    ../modules/rootless.nix

    ../profiles/core
    ../profiles/networking
    ../profiles/nas

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # For Sonarr
  # TODO: remove when unnecessary
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  users.users.root = userConfig;
  # users.users.leander = userConfig;

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.device = "nodev";

  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd.network = {
    enable = true;
    udhcpc.enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      authorizedKeys = secrets.ssh.authorizedKeys.keys;
    };
  };
  environment.persistence."/persist" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    directories = [
      { directory = "/var/lib/acme"; user = "acme"; group = "acme"; mode = "0750"; }
      { directory = "/var/lib/nixos"; user = "root"; group = "root"; mode = "0750"; }
    ];
  };
  systemd.services.sshd.wantedBy = [ "emergency.target" ];

  age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.wireguard-private.file = ../secrets/storig-wireguard-private.age;
  age.secrets.wireguard-psk.file = ../secrets/storig-wireguard-psk.age;

  services.fwupd.enable = true;

  networking.useNetworkd = true;
  networking.dhcpcd.enable = false; # Use networkd instead
  networking.networkmanager.enable = lib.mkForce false;
  networking.hostId = "50fb60de";
  networking.hostName = "storig";
  services.nscd.enableNsncd = false;
  systemd.network.wait-online.extraArgs = [ "-i" "enp3s0" ];
  systemd.network.networks."10-enp3s0" = {
    matchConfig.Name = "enp3s0";
    DHCP = "yes";
    address = [ "192.168.129.250" ];
    dns = [ "1.1.1.1" "1.0.0.1" ];
  };

  networking.interfaces.enp3s0.ipv4.addresses = [
    {
      address = builtins.head config.systemd.network.networks."10-enp3s0".address;
      prefixLength = 23;
    }
  ];

  rootless = {
    enable = true;
    zfsPart = "rpool/nixos/root";
    dataPaths = [
      "/etc/nixos"
    ];
  };

  environment.etc."machine-id" = {
    user = "root";
    group = "root";
    text = "50fb60de6a044574984f83866388199f";
  };

  fileSystems."/" = {
    device = "rpool/nixos/root";
    fsType = "zfs";
    options = [ "x-mount.mkdir" ];
  };

  fileSystems."/var/log" = {
    device = "rpool/nixos/var/log";
    fsType = "zfs";
    options = [ "x-mount.mkdir" ];
  };

  fileSystems."/nix" = {
    device = "rpool/nixos/nix";
    fsType = "zfs";
    options = [ "x-mount.mkdir" ];
  };

  fileSystems."/persist" = {
    device = "rpool/nixos/persist";
    fsType = "zfs";
    options = [ "x-mount.mkdir" ];
    neededForBoot = true;
  };

  systemd.services.zfs-load-key-naspool1 = {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.zfs}/bin/zfs load-key -r naspool1";
    };
    requires = [ "persist.mount" "zfs-import-naspool1.service" ];
    after = [ "persist.mount" "zfs-import-naspool1.service" ];
    requiredBy = [ "zfs-mount.service" ];
    before = [ "zfs-mount.service" ];
  };

  # fileSystems."/media/naspool1" = {
  #   device = "naspool1";
  #   fsType = "zfs";
  #   options = [ "x-mount.mkdir" "x-systemd.after=zfs-load-key-naspool1.service" "x-systemd.requires=zfs-load-key-naspool1.service" ];
  # };
  fileSystems."/media/naspool1/media" = {
    device = "naspool1/media";
    fsType = "zfs";
    options = [ "x-mount.mkdir" "x-systemd.after=zfs-load-key-naspool1.service" "x-systemd.requires=zfs-load-key-naspool1.service" ];
  };
  fileSystems."/media/naspool1/data" = {
    device = "naspool1/data";
    fsType = "zfs";
    options = [ "x-mount.mkdir" "x-systemd.after=zfs-load-key-naspool1.service" "x-systemd.requires=zfs-load-key-naspool1.service" ];
  };

  fileSystems."/boot" = {
    device = "bpool/nixos/root";
    fsType = "zfs";
    options = [ "x-mount.mkdir" "x-systemd.automount" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/09EC-9532";
    fsType = "vfat";
    options = [ "x-systemd.automount" ];
  };


  boot.zfs.extraPools = [ "naspool1" ];

  swapDevices =
    [{ device = "/dev/disk/by-uuid/0883dbcc-a1e9-4026-bde1-3dd92c7f2d8c"; }];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "r8169" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  system.stateVersion = "22.11";
}
