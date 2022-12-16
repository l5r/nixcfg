{ config, lib, pkgs, ... }: {
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
}
