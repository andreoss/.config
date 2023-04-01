{ lib, config, pkgs, ... }: {
  config = {
    boot.loader = {
      grub = {
        efiSupport = false;
        enableCryptodisk = true;
        enable = true;
        splashImage = ../wp/1.jpeg;
        splashMode = "normal";
        theme = null;
        version = 2;
      };
    };
  };
}
