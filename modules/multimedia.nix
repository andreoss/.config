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
    services.playerctld = {
      enable = cfg.enable;
    };
    home.packages = with pkgs; [
      heimdal
      ffmpeg-full
      scrcpy
      android-tools
      imagemagickBig
      reco
      farbfeld
      mpc
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
