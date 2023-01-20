{ lib, config, pkgs, ... }: {
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      efiSupport = false;
      device = "/dev/sdb";
    };
  };
}
