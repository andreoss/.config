{ lib, config, pkgs, ... }: {
  boot.loader = {

    grub = {
      device = "/dev/sdb";
      efiSupport = false;
      enableCryptodisk = true;
      enable = true;
      splashImage = ../wp/1.jpeg;
      splashMode = "normal";
      theme = null;
      version = 2;
    };
  };
}
