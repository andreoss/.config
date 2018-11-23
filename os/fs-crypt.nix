{ config, lib, pkgs, modulesPath, self, ... }:
let btrfsOptions = self.config.fileSystems.btrfsOptions;
in {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.initrd.luks.devices."luks-system".device =
    "/dev/disk/by-partuuid/11111111-1111-1111-1111-111111111111";
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
    };
    "/nix/store" = {
      device = "/dev/disk/by-uuid/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
      fsType = "btrfs";
      options = [ "subvol=nix-store" ] ++ btrfsOptions;
    };
    "/nix/var" = {
      device = "/dev/disk/by-uuid/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
      fsType = "btrfs";
      options = [ "subvol=nix-var" ] ++ btrfsOptions;
    };
    "/gnu/store" = {
      device = "/dev/disk/by-uuid/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
      fsType = "btrfs";
      options = [ "subvol=gnu-store" ] ++ btrfsOptions;
    };
    "/var/guix" = {
      device = "/dev/disk/by-uuid/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
      fsType = "btrfs";
      options = [ "subvol=guix-var" ] ++ btrfsOptions;
    };
    "/user" = {
      device = "/dev/disk/by-uuid/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
      fsType = "btrfs";
      options = [ "subvol=user" ] ++ btrfsOptions;
    };
    "/etc/nixos" = {
      device = "/dev/disk/by-uuid/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
      fsType = "btrfs";
      options = [ "subvol=etc-nixos" ] ++ btrfsOptions;
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/00000000-0000-0000-0000-000000000000";
      fsType = "vfat";
    };
  };
  swapDevices = [ ];
}
