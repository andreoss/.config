{
  config,
  lib,
  ...
}:
let
  palette = import ../os/palette.nix;
in
{
  config = {
    services.dunst = {
      enable = config.xsession.enable;
      settings = with palette; {
        global = {
          frame_color = black1;
          separator_color = gray4;
          transparency = 10;
          font = "Terminus";
          alignment = "center";
          word_warp = "true";
          line_height = 3;
          geometry = "600x5-30+20";
        };
        urgency_low = {
          background = gray5;
          foreground = black0;
          timeout = 3600;
        };
        urgency_normal = {
          background = gray5;
          foreground = black0;
          timeout = 180;
        };
        urgency_critical = {
          background = white3;
          foreground = black1;
          frame_color = red1;
          timeout = 0;
        };
      };
    };
  };
}
