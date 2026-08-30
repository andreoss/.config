{
  config,
  pkgs,
  lib,
  ...
}:
let
  palette = import ../os/palette.nix;
  cfg = config.home.multimedia;
in
{
  config = {
    home.file = lib.mkIf config.programs.mpv.enable {
      ".local/bin/mpv-hdmi" = {
        executable = true;
        text = ''
          #!/bin/sh
          mpv --vo=drm --drm-connector=HDMI-A-1 "$@"
        '';
      };
      ".local/bin/duration" = {
        executable = true;
        text = ''
          #!/bin/sh
          set -e
          __error() {
                    >&2 echo "$*"
                    exit 3
          }
          __duration() {
             test -f "$1" || __error "file not found '$1'"
             ffprobe -i "$1" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal
          }
          __duration "$1"
        '';
      };
      ".local/bin/mpa" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec mpv --vo=null "$@"
        '';
      };
    };
    programs.mpv = {
      enable = cfg.enable;
      bindings = {
        "Alt+0" = "set window-scale 0.5";
        "ALT+j" = "add sub-scale +0.1";
        "ALT+k" = "add sub-scale -0.1";
        WHEEL_DOWN = "seek -10";
        WHEEL_UP = "seek 10";
      };
      config = {
        osc = "yes";
        osd-color = palette.blue4;
        sub-color = palette.white4;
        sub-shadow-color = palette.black2;
        osd-font-size = 24;
        save-position-on-quit = true;
        sub-border-size = 1;
        sub-shadow-offset = 2;
      };
      scripts = with pkgs.mpvScripts; [
        mpris
        thumbnail
        visualizer
      ];
    };
  };
}
