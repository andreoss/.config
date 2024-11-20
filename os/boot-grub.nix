{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = {
    boot.loader = {
      grub = {
        configurationLimit = 5;
        efiSupport = false;
        enableCryptodisk = true;
        enable = true;
        splashImage = config.backgroundImage;
        splashMode = "stretch";
        theme = null;
        fontSize = 36;
        font = "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF-Bold.ttf";
      };
    };
  };
}
