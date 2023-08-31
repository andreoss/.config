{ config, lib, pkgs, modulesPath, ... }:

let host = "0007";
in {
  boot.initrd = {
    luks.devices = {
      "system-${host}" = {
        device =
          "/dev/disk/by-partuuid/00000000-0000-0000-${host}-000000000002";
      };
    };

  };
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/${host}-0011";
      fsType = "vfat";
    };

    "/nix/store" = {
      device = "/dev/mapper/system-${host}";
      fsType = "btrfs";
      options = [ "subvol=nix-store" ];
    };

    "/nix/var" = {
      device = "/dev/mapper/system-${host}";
      fsType = "btrfs";
      options = [ "subvol=nix-var" ];
    };

    "/user" = {
      device = "/dev/mapper/system-${host}";
      fsType = "btrfs";
      options = [ "subvol=user" ];
    };
    "/var" = {
      device = "/dev/mapper/system-${host}";
      fsType = "btrfs";
      options = [ "subvol=var" ];
    };

  };
  swapDevices = [ ];
}
