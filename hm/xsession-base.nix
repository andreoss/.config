{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  palette = import ../os/palette.nix;
  font = "Terminus";
  icons-src = pkgs.fetchzip {
    url = "https://codeload.github.com/B00merang-Artwork/Windows-XP/zip/refs/heads/master";
    sha256 = "sha256-xHc7JRXwgiiHRl18CnMV+Zwic9BU4XoNoEvkDbmyo/8=";
    extension = "zip";
  };
in
{
  options = { };
  config = {
    home.pointerCursor = {
      name = "Windows-XP";
      x11.enable = config.xsession.enable;
      x11.defaultCursor = "left_ptr";
      package = (
        pkgs.runCommand "icons" { nativeBuildInputs = [ icons-src ]; }
          "mkdir --parent $out/share/icons/Windows-XP; cp --recursive ${icons-src}/* $out/share/icons/Windows-XP/"
      );
    };
    gtk = {
      enable = config.xsession.enable;
      font.package = pkgs.terminus_font_ttf;
      font.name = "${font} 9";
      iconTheme = {
        name = "Windows-XP";
      };
      gtk2.extraConfig = "";
      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull";
        gtk-xft-rgba = "rgb";
        gtk-fallback-icon-theme = "gnome";
        gtk-button-images = 0;
        gtk-cursor-theme-size = 0;
        gtk-enable-animations = false;
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
      };
      gtk3.bookmarks = [
        "file://${config.home.homeDirectory}/Книги/"
        "file://${config.home.homeDirectory}/Код/"
        "file://${config.home.homeDirectory}/Работа/"
        "file://${config.home.homeDirectory}/Документы/"
      ];
    };
    qt = {
      enable = config.xsession.enable;
      style.package = pkgs.adwaita-qt;
    };
    programs.feh.enable = config.xsession.enable;
    programs.rofi = {
      enable = config.xsession.enable;
      cycle = true;
      terminal = "urxvt";
      theme = "gruvbox-light-soft";
    };
    fonts.fontconfig.enable = config.xsession.enable;
    home.packages = lib.optionals config.xsession.enable (
      with pkgs;
      [
        alock
        fontpreview
        luculent
        paratype-pt-mono
        recursive
        sudo-font
        terminus_font
        terminus_font_ttf
        uni-vga
        uw-ttyp0
        wmctrl
        wmname
        xclip
        xdotool
        xorg.xdpyinfo
        xorg.xwininfo
        xorg.xev
        xorg.xhost
        xorg.xprop
        xorg.xrandr
        xorg.xkill
        xorg.xwd
        xpra
      ]
    );
    home.sessionVariables = lib.mkIf config.xsession.enable {
      XDG_SESSION_PATH = "";
      XDG_SESSION_DESKTOP = "";
      XDG_SESSION_TYPE = "";
      XDG_SESSION_CLASS = "";
      XDG_SESSION_ID = "";
      XDG_CURRENT_SESSION = "";
      GDMSESSION = "";
      DESKTOP_SESSION = "";
    };
  };
}
