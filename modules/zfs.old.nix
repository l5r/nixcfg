{ config, lib, pkgs, ... }:
let
  secrets = import ../secrets;
in
{
  fileSystems."/nix" = {
    device = "rpool/secure/nixos/nix";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "rpool/secure/nixos/persist";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/secure/home";
    fsType = "zfs";
  };

  fileSystems."/etc/nixos" = {
    device = "rpool/secure/nixos/config";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/zvol/rpool/secure/swap"; }
  ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
}
