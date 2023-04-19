{ lib, config, pkgs, ... }: {
  config = {
    boot.loader = {
      grub = {
        efiSupport = false;
        enableCryptodisk = true;
        enable = true;
        splashImage = ../wp/1.jpeg;
        splashMode = "stretch";
        theme = null;
        version = 2;
        gfxmodeBios = "1920x1080";
        gfxmodeEfi = "1920x1080";
        fontSize = 24;
        font =
          "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF-Bold.ttf";
      };
    };
  };
}
