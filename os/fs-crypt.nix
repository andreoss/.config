{ config, lib, pkgs, modulesPath, self, ... }:
let btrfsOptions = config.ao.fileSystems.btrfsOptions;
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
  systemd.services = {
    create-swapfile = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "nix-var-swap.swap" ];
      script = ''
        ${pkgs.coreutils}/bin/truncate -s 0 /nix/var/swap
        ${pkgs.e2fsprogs}/bin/chattr +C /nix/var/swap
        ${pkgs.btrfs-progs}/bin/btrfs property set /nix/var/swap compression none
      '';
    };
  };
  zramSwap.enable = false;
  swapDevices = [{
    device = "/nix/var/swap";
    size = (1024 * 16) + (1024 * 2); # RAM size + 2 GB
  }];
}
