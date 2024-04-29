{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  config = {
    fonts = {
      fontDir = {
        enable = true;
      };
      enableDefaultPackages = true;
      enableGhostscriptFonts = true;
      packages = with pkgs; [
        terminus_font
        terminus_font_ttf
        spleen
      ];
      fontconfig = {
        hinting.enable = true;
        hinting.autohint = true;
        hinting.style = "full";
        useEmbeddedBitmaps = true;
        defaultFonts = {
          monospace = [ "Spleen" ];
          sansSerif = [ "Terminus" ];
          serif = [ "Terminus" ];
        };
      };
    };
  };
}
