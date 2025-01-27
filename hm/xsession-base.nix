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
    sha256 = "sha256-TzgvvwAdqUmbdQJ0jARKXAObyHQVyGv4TJyI2dH4YiE=";
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
    home.activation = lib.mkIf config.services.sxhkd.enable {
      sxhkdUpdate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.procps}/bin/pgrep sxhkd && ${pkgs.procps}/bin/pkill -USR1 sxhkd
      '';
    };
    programs.feh.enable = config.xsession.enable;
    programs.rofi = {
      enable = config.xsession.enable;
      cycle = true;
      terminal = "urxvt";
      theme = "gruvbox-light-soft";
    };
    services.sxhkd = {
      enable = config.xsession.enable;
      keybindings = {
        "alt + slash" = "dbus-launch rofi -show-icons -show combi";
        "ctrl + alt + slash" = "dbus-launch rofi -show-icons -show filebrowser";
        "alt + BackSpace" = "${inputs.dmenu.packages.x86_64-linux.dmenu}/bin/dmenu_run";
      };
    };
    services.dunst = {
      enable = config.xsession.enable;
      settings = with palette; {
        global = {
          frame_color = black1;
          separator_color = gray4;
          transparency = 10;
          font = "${font}";
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
    systemd.user.services = lib.mkIf config.xsession.enable {
      wpa = {
        Unit = {
          Description = "wpa";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10s";
          ExecStart = "${pkgs.wpa_supplicant_gui}/bin/wpa_gui -t";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
      fehbg = {
        Unit = {
          Description = "fehbg";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 5s";
          ExecStart = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${config.backgroundImage}";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
