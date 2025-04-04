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
  imports = [ ];
  options = {
    home.multimedia = {
      enable = lib.mkEnableOption "Multimedia programs.";
      default = false;
    };
  };
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
    services.playerctld = {
      enable = cfg.enable;
    };
    services.sxhkd = lib.mkIf config.services.playerctld.enable {
      keybindings = {
        "XF86AudioPlay" = "playerctl play-pause";
        "XF86AudioStop" = "playerctl stop";
        "XF86AudioPrev" = "playerctl previous";
        "XF86AudioNext" = "playerctl next";
        "XF86Tools" = "playerctl previous";
        "XF86LaunchA" = "playerctl stop";
        "XF86Explorer" = "playerctl next";
        "XF86Search" = "playerctl play-pause";
        "XF86AudioMute" =
          ''${pkgs.pamixer}/bin/pamixer --toggle-mute && ${pkgs.libnotify}/bin/notify-send --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioMicMute" =
          ''${pkgs.pamixer}/bin/pamixer --toggle-mute --default-source && ${pkgs.libnotify}/bin/notify-send --expire-time=3000 --urgency=critical --replace-id=16 "🎤 $(${pkgs.pamixer}/bin/pamixer --get-volume-human --default-source)"'';
        "XF86AudioLowerVolume" =
          ''${pkgs.pamixer}/bin/pamixer --decrease 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioRaiseVolume" =
          ''${pkgs.pamixer}/bin/pamixer --increase 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
      };
    };
    home.packages = with pkgs; [
      heimdal
      ffmpeg-full
      scrcpy
      android-tools
      imagemagickBig
      audio-recorder
      farbfeld
      mpc_cli
      pavucontrol
      playerctl
      pulsemixer
      vlc
      exiftool
    ];
    services.mpdris2 = {
      notifications = true;
      enable = cfg.enable;
    };
    programs.ncmpcpp = {
      enable = cfg.enable;
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
    services.mpd = {
      enable = cfg.enable;
      musicDirectory = "${config.home.homeDirectory}/Music";
      extraConfig = ''
        follow_outside_symlinks "yes"
        follow_inside_symlinks "yes"
      '';
    };
    programs.yt-dlp = {
      enable = cfg.enable;
      settings = {
        downloader-args = "aria2c:'-c -x8 -s8 -k1M --allow-overwrite=true'";
        downloader = "aria2c";
        compat-options = "no-certifi";
        embed-chapters = true;
        embed-info-json = true;
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;
        format = "bestvideo[height<=1080]+bestaudio[ext=m4a]";
        merge-output-format = "mkv";
        mtime = true;
        no-part = true;
        retries = 50;
        sub-langs = "(fr|en|es|pt|ru).*";
        windows-filenames = true;
        write-auto-sub = true;
        write-sub = true;
      };
    };
  };
}
