{
  config,
  lib,
  pkgs,
  modulesPath,
  host,
  ...
}:
let
  host = config.hostId;
in
{
  boot.initrd = {
    secrets = {
      "/etc/luks/system" = ../secrets/system-${host};
    };
    luks.devices = {
      "system-${host}" = {
        keyFile = "/etc/luks/system";
        device = "/dev/disk/by-partuuid/00000000-0000-0000-${host}-000000000002";
      };
    };
  };
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-partuuid/00000000-0000-0000-${host}-000000000001";
      fsType = "vfat";
    };
    "/boot" = {
      device = "/dev/mapper/system-${host}";
      fsType = "btrfs";
      options = [ "subvol=boot" ];
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
