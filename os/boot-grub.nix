{ lib, config, pkgs, ... }: {
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      enableCryptodisk = true;
      efiSupport = false;
      device = "/dev/sdb";
    };
  };
}
