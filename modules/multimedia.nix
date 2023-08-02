{ config, pkgs, lib, ... }:
let
  palette = import ../os/palette.nix;
  cfg = config.home.multimedia;
in {
  imports = [ ];
  options = {
    home.multimedia = {
      enable = lib.mkEnableOption "Multimedia programs.";
      default = false;
    };
  };
  config = {
    home.file = lib.mkIf config.programs.mpv.enable {
      ".local/bin/mpa" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec mpv --vo=null "$@"
        '';
      };
    };
    services.playerctld = { enable = cfg.enable; };
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
        "XF86AudioMute" = ''
          ${pkgs.pamixer}/bin/pamixer --toggle-mute && ${pkgs.libnotify}/bin/notify-send --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioMicMute" = ''
          ${pkgs.pamixer}/bin/pamixer --toggle-mute --default-source && ${pkgs.libnotify}/bin/notify-send --expire-time=3000 --urgency=critical --replace-id=16 "🎤 $(${pkgs.pamixer}/bin/pamixer --get-volume-human --default-source)"'';
        "XF86AudioLowerVolume" = ''
          ${pkgs.pamixer}/bin/pamixer --decrease 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
        "XF86AudioRaiseVolume" = ''
          ${pkgs.pamixer}/bin/pamixer --increase 8 && ${pkgs.libnotify}/bin/notify-send --expire-time=500 --urgency=low --replace-id=17 "🔈 $(${pkgs.pamixer}/bin/pamixer --get-volume-human)"'';
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
    programs.ncmpcpp = { enable = cfg.enable; };
    programs.mpv = {
      enable = cfg.enable;
      config = {
        save-position-on-quit = true;
        osc = "yes";
        osd-font-size = 24;
        osd-color = palette.white2;
      };
      scripts = with pkgs.mpvScripts; [ mpris ];
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
        convert-subs = "srt";
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;
        mtime = true;
        sub-langs = "all";
      } // lib.mkIf config.programs.aria2.enable {
        downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
        downloader = "aria2c";
      };
    };
  };
}
