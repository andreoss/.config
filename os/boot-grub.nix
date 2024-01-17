{ lib, config, pkgs, ... }: {
  config = {
    boot.loader = {
      grub = {
        configurationLimit = 5;
        efiSupport = false;
        enableCryptodisk = true;
        enable = true;
        splashImage = ../wp/1.jpeg;
        splashMode = "stretch";
        theme = null;
        gfxmodeBios = "1920x1080";
        gfxmodeEfi = "1920x1080";
        fontSize = 36;
        font =
          "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF-Bold.ttf";
      };
    };
  };
}
